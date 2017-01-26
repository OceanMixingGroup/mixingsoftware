function [cal,data,head]=get_chipod_cals(dpath,dpl,unit,ts,tf,depth,...
    hpf_cutoff,use_n2,time_offset)
% 
% function [cal,data,head]=get_chipod_cals(dpath,dpl,unit,ts,tf,depth,...
%    hpf_cutoff,use_n2,time_offset)
%
% get clibrated chipod data and buoy current and from time ts to time tf.
% Calcualte the motion of the chipod relative to the currents.
%
% dpath - data directory, i.e. '\\ganges\data\chipod\tao_sep05\'
% dpl - deployment name (string), i.e. 'or07b'
% unit - unit number, (integer) i.e. 305
% ts - start time, Matlab format
% tf - finish time, Matlab format
% depth - unit depth, it is necessarry for current data interpolation
% hpf_cutoff - hpf filter cutoff in Hz. - optional, but should be adjusted  
% for every cruise!!!  
%   $Revision: 1.18 $  $Date: 2012/12/28 21:15:52 $
%
% April 2014 - sjw
% changed line 108:
% OLD: cal.(char(fields(ii)))=interp1(moor.curtime,moor.(char(fields(ii))),cal.time_acc,'spline');
% NEW: cal.(char(fields(ii)))=interp1(moor.curtime,moor.(char(fields(ii))),cal.time_acc);
% Using "spline" to interpolate the data from the mooring leads to some
% very erronious values of dTdz and N2. 



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%% (sjw) run as independent code %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% for debugging %%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% to switch to a function remember to:
% 1. uncomment line 1
% 2. uncomment nargins between the %%%s
% 3. comment out the input stuff below
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% clear all
% dpath = '~/ganges/data/chipod/TAO11_140/';
% dpl = 'tao11_140';
% unit = 312;
% ts = datenum(2011,9,3,0,0,0);
% tf = datenum(2011,9,3,2,0,0);
% depth = 29;
% hpf_cutoff=0.04;
% use_n2=0;
% time_offset = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%% get inputs

clear vel disp
unitstr=num2str(unit);

%%%
if nargin<9
    time_offset=0;
end
if nargin<8
    use_n2=0;
end
%%%


%% load

% load raw data
[data,head]=get_chipod_raw(dpath,dpl,unit,ts,tf,time_offset);

% if there is no data in the raw file, end this function returning an empty
% cal to run_calc_chipod_chi
if isempty(data)
    cal=[];
    return
end

% calibrate raw data
[cal,head]=eval(['cali_chipod_' dpl '(data,head,unit)']);


% load mooring temperature, salinity and velocity
[moor]=get_mooring(dpath,ts,tf,depth,dpl,unit);
moor.N2b = moor.N2;
moor.dTdzb = moor.dTdz;


%% calcualte chipod motion and current speeds

% calculate accelerometer time
% (sjw 1/2016) Note, it is OKAY that with older 120 Hz chipods (version48)
% cal.time_acc is at 120Hz (frequency of T1P, T2P, AX, AY, Ax, etc.; cal.time at 10 Hz), 
% whereas for the newer chipods (version80) cal.time_acc is at 50Hz
% (frequency of AX, AY, AZ) and not at 100Hz (frequency of T1P, T2P and time)
if any(head.version==[16 32 48 64])
    cal.time_acc=interp1(1:length(cal.time),cal.time,[1:length(cal.AX)]/...
        head.submax_oversample,'linear','extrap');
else
    cal.time_acc=cal.time(1:head.submax_oversample:end);
end

%%%%% find the right fields within moor and correlate the time
% list all of the fields within the structure moor
% (curtime,N2,dTdz,u,v,w,spd,dir)
fields=fieldnames(moor);
% set diff removes variables from the list in fields
fields=setdiff(fields,'curtime');
% if use_n2==0 (we want to use the LOCAL dTdz as opposed to the dTdz and N2
% from the mooring), then REMOVE N2 and dTdz from the list in fields
if use_n2==0
    fields=setdiff(fields,{'N2','dTdz'});
end
% put all of the remaining variables listed in fields into the cal
% structure by interpolating them to the cal.time_acc time grid
% (if use_N2==1, cal will contain N2,dTdz,dir,spd,u,v,w, otherwise, if
% use_N2==0, cal will contain dir,spd,u,v,w)
for ii=1:length(fields)
    cal.(char(fields(ii)))=interp1(moor.curtime,moor.(char(fields(ii))),cal.time_acc);
end

% make current vectors with the correct name
cal.cur_u=cal.u;
cal.cur_v=cal.v;
cal.curspd=cal.spd;
cal=rmfield(cal,{'u','v','spd'});

% make sure velocity and acceleration vectors are the same length
if size(cal.cur_u,1)~=size(cal.AX,1)
    for ii=1:length(fields)
        cal.(char(fields(ii)))=cal.(char(fields(ii)))';
    end
end

% calculate motion of chipod and currents
if any(head.version==[16 32 48 64]) && isfield(cal,'RX') && ~all(isnan(cal.CMP))
    % filter rate sensor data and get high-freq rotations
    cal=calc_filtered_rotations(cal,head);
    
    % calculate low-freq rotations from accelerometer data
    cal=calc_lp_rotations(cal,head);
    
    % Remove gravitational part from acceleration measurements
    cal.roll=cal.rlp+cal.alphaX;cal.roll=fillgap(cal.roll,1);
    cal.pitch=cal.plp+cal.alphaY;cal.pitch=fillgap(cal.pitch,1);
    cal.yaw=cal.ylp+cal.alphaZ;cal.yaw=fillgap(cal.yaw,1);
    cal=remove_gravitation(cal,head);
    
    % compute mean yaw and mean compass angles
    ttt=exp(sqrt(-1)*cal.yaw*pi/180);
    uyaw=real(ttt); vyaw=imag(ttt);
    meanyaw=atan2(nanmean(vyaw),nanmean(uyaw))*180/pi;
    meanyaw(meanyaw<0)=meanyaw(meanyaw<0)+360;
    ttt=exp(sqrt(-1)*cal.CMP*pi/180);
    ucmp=real(ttt); vcmp=imag(ttt);
    meancmp=atan2(nanmean(vcmp),nanmean(ucmp))*180/pi;
    meancmp(meancmp<0)=meancmp(meancmp<0)+360;
    
    % rotate yaw to correspond to compass
    % we subtract compass reading because compass is in left-hand coordinate
    % system (alphaZ is a mirror image of compass)
    cal.yaw=cal.yaw-meanyaw-meancmp;
    
    % add 90 degrees because axis X (u component of velocity) points East (not North)
    cal.yaw=cal.yaw+90;
    cal.yaw(cal.yaw>180)=cal.yaw(cal.yaw>180)-360;
    cal.yaw(cal.yaw<=-180)=cal.yaw(cal.yaw<=-180)+360;
    
    % translate current components to BCS. We assume that we know pitch and
    % roll of Chipod relatively to LCS. Using these data we can translate
    % current vector to BCS at each time step.
    r=cal.roll;
    p=cal.pitch;
    y=cal.yaw;
    if size(r,2)>1; r=r';p=p';y=y'; end
    curu=cal.cur_u;
    curv=cal.cur_v;
    curw=0*curu;
    if size(curu,2)>1;curu=curu';curv=curv';curw=curw';end
    [cal.cur_x cal.cur_y cal.cur_z] = translatevectorrpy([-r -p -y],[curu curv curw],'degrees');
    if size(cal.cur_x,1)~=size(cal.AX,1)
        cal.cur_x=cal.cur_x';
        cal.cur_y=cal.cur_y';
        cal.cur_z=cal.cur_z';
    end
    r1tip=1.818*2.54/100;% distance from cable to shorter sensor tip
    ra=3.3*0.0254;% distance from accelerometer package to cable 
    dyawdt=gradient(cal.yaw*pi/180,1/head.samplerate(head.sensor_index.R1));
    dyawdt=deglitch(dyawdt,30,2);
    dyawdt=fillgap(dyawdt,1);
    cal.r1omega=(ra+r1tip)*dyawdt;
    
    % Calculate Chipod motion in BCS
    [disp,vel]=integrate_acc(cal,head,hpf_cutoff);
    cal.dispx=disp.x;
    cal.dispy=disp.y;
    cal.dispz=disp.z;
    cal.velx=vel.x;
    cal.vely=vel.y;
    cal.velz=vel.z;
    cal.fspd=sqrt((cal.velx-cal.cur_x).^2+(cal.vely-(cal.cur_y+cal.r1omega)).^2+...
        (cal.velz-cal.cur_z).^2);
    
    % Transform accelerations from BCS to ENU - A(e,n,u)=R(r,p,y)*A(x,y,z)
    AX=cal.AX;if size(AX,2)>1;AX=AX';end
    AY=cal.AY;if size(AY,2)>1;AY=AY';end
    AZ=cal.AZ;if size(AZ,2)>1;AZ=AZ';end
    [cal.AE cal.AN cal.AU] = translatevectorrpy([r p y],[AX AY AZ],'degrees');
    if size(cal.AE,1)~=size(cal.AX,1);cal.AE=cal.AE';cal.AN=cal.AN';cal.AU=cal.AU';end
    
    % Calculate Chipod motion in ENU
    temp.AX=cal.AE;
    temp.AY=cal.AN;
    temp.AZ=cal.AU;
    temp.AX=fillgap(cal.AX);
    temp.AY=fillgap(cal.AY);
    temp.AZ=fillgap(cal.AZ);
    [disp,vel]=integrate_acc(temp,head,hpf_cutoff);
    cal.dispe=disp.x;
    cal.dispn=disp.y;
    cal.dispu=disp.z;
    cal.vele=vel.x;
    cal.veln=vel.y;
    cal.velu=vel.z;
    
% for the chipods that are not versions [16 32 48 64] and Rx does not exist    
elseif ~all(isnan(cal.CMP))
    % here we compute fall speed using compass as yaw and
    % low-passed pitch and roll (the closest to we can get without rate sensors):
    % (components of current in Chipod coordinate system)
    % calculate low-freq rotations from accelerometer data
    cal=calc_lp_rotations(cal,head);
    
    % Remove gravitational part from acceleration measurements
    cal.roll=cal.rlp;cal.roll=fillgap(cal.roll,1);
    cal.pitch=cal.plp;cal.pitch=fillgap(cal.pitch,1);
    cal=remove_gravitation(cal,head);
    [time itime]=unique(cal.time_acc(1:head.samplerate(head.sensor_index.AX)/head.slow_samp_rate:end)-1/86400);
    cmp=exp(sqrt(-1)*cal.CMP(itime)*pi/180);
    cmpu=real(cmp); cmpv=imag(cmp);
    cmpu=interp1(time,cmpu,cal.time_acc,'linear','extrap');
    cmpv=interp1(time,cmpv,cal.time_acc,'linear','extrap');
    CMP_fast=atan2(cmpv,cmpu)*180/pi;
    cal.cur_x=cal.cur_u.*sind(CMP_fast)+cal.cur_v.*cosd(CMP_fast);
    cal.cur_y=-cal.cur_u.*cosd(CMP_fast)+cal.cur_v.*sind(CMP_fast);
    r1tip=1.818*2.54/100;% distance from cable to shorter sensor tip
    ra=3.3*0.0254;% distance from accelerometer package to cable 
    dyawdt=gradient(-CMP_fast*pi/180,1/head.samplerate(head.sensor_index.AX));dyawdt=deglitch(dyawdt,30,2);dyawdt=fillgap(dyawdt,1);
    if isnan(dyawdt(1)); dyawdt(1)=dyawdt(2);end
    if isnan(dyawdt(end)); dyawdt(end)=dyawdt(end-1);end
    cal.r1omega=(ra+r1tip)*dyawdt;
    cal.AX=fillgap(cal.AX);
    cal.AY=fillgap(cal.AY);
    cal.AZ=fillgap(cal.AZ);
    [disp,vel]=integrate_acc(cal,head,hpf_cutoff);
    cal.velz=vel.z;
    cal.vely=vel.y;
    cal.velx=vel.x;
    cal.dispz=disp.z;
    cal.dispy=disp.y;
    cal.dispx=disp.x;
    % calculate fallspeed
    cal.fspd=sqrt((cal.velx-cal.cur_x).^2+(cal.vely-(cal.cur_y+cal.r1omega)).^2+cal.velz.^2);
    if isfield(data,'W1')
        r2tip=3.76*2.54/100;% distance from longer sensor tip (3 pitot unit)to cable
        cal.r1omega_3P=(ra+r2tip)*dyawdt;
        cal.fspd_3P=sqrt((cal.velx-cal.cur_x).^2+(cal.vely-(cal.cur_y+cal.r1omega_3P)).^2+cal.velz.^2);
    end
    
% for the cases with no compass   
else
    cal.cur_x=NaN*cal.cur_u;
    cal.cur_y=NaN*cal.cur_u;
    % calculate low-passed pitch and roll from accelerometer data
    cal=calc_lp_rotations(cal,head);
    % Remove gravitational part from acceleration measurements
    cal.roll=cal.rlp;cal.roll=fillgap(cal.roll,1);
    cal.pitch=cal.plp;cal.pitch=fillgap(cal.pitch,1);
    cal=remove_gravitation(cal,head);
    cal.AX=fillgap(cal.AX);
    cal.AY=fillgap(cal.AY);
    cal.AZ=fillgap(cal.AZ);
    [disp,vel]=integrate_acc(cal,head,hpf_cutoff);
    cal.velz=vel.z;
    cal.vely=vel.y;
    cal.velx=vel.x;
    cal.dispz=disp.z;
    cal.dispy=disp.y;
    cal.dispx=disp.x;
    cal.fspd=sqrt((cal.curspd+cal.velx).^2+cal.vely.^2+cal.velz.^2);
end



data.T1P=data.T1P-nanmean(data.T1P);
data.T2P=data.T2P-nanmean(data.T2P);

cal.T1Px=calibrate_tp(data.T1P,head.coef.T1P,data.T1,head.coef.T1,100*cal.fspd');
cal.T2Px=calibrate_tp(data.T2P,head.coef.T2P,data.T2,head.coef.T2,100*cal.fspd');
cal.T1Pt=calibrate_tp(data.T1P,head.coef.T1P,data.T1,head.coef.T1,100*ones(size(cal.fspd')));
cal.T2Pt=calibrate_tp(data.T2P,head.coef.T2P,data.T2,head.coef.T2,100*ones(size(cal.fspd')));













