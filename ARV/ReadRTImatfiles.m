function vel=ReadRTImatfiles(datdir,flist)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function vel=ReadRTImatfiles(flist)
%
% Read RTI (Rowe Technology inc) ADCP ensembles from files in flist and assemble into one structure
% 'vel'. This is for files that are converted to mat files using the
% 'Pulse' software. Each file is one ensemble.
%
% Info on the variables and file structure is given in the "RTI ADCP DVL USER GUIDE"
%
%
% April 6 2015 - A. Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

% load 1 file first to get number of bins for array size
load(fullfile(datdir,flist(1).name))
EnsDat=E000008;
Nbins=EnsDat(2);

% make empty arrays for data
Nens=length(flist);
vel=struct();
vel.ens_num=nan*ones(1,Nens);
vel.dnum=nan*ones(1,Nens);
vel.heading=nan*ones(1,Nens);
vel.pitch=nan*ones(1,Nens);
vel.roll=nan*ones(1,Nens);
vel.bt_range0=nan*ones(1,Nens);
vel.bt_range1=nan*ones(1,Nens);
vel.bt_range2=nan*ones(1,Nens);
vel.bt_range3=nan*ones(1,Nens);
vel.bt_status=nan*ones(1,Nens);
vel.bt_u=nan*ones(1,Nens);
vel.bt_v=nan*ones(1,Nens);
vel.bt_w=nan*ones(1,Nens);
EmpMat=nan*ones(Nbins,Nens);

% beam velocities
vel.BmVel0=EmpMat;
vel.BmVel1=EmpMat;
vel.BmVel2=EmpMat;
vel.BmVel3=EmpMat;

% instrument velocities
vel.X=EmpMat;
vel.Y=EmpMat;
vel.Z=EmpMat;
vel.Q=EmpMat;

% earth velocities
vel.u=EmpMat;
vel.v=EmpMat;
vel.w=EmpMat;
vel.Q=EmpMat;

% beam amplitudes
vel.amp0=EmpMat;
vel.amp1=EmpMat;
vel.amp2=EmpMat;
vel.amp3=EmpMat;

% beam correlations
vel.corr0=EmpMat;
vel.corr1=EmpMat;
vel.corr2=EmpMat;
vel.corr3=EmpMat;
%

hb=waitbar(0,'Reading data files')
for a=1:Nens
    waitbar(a/Nens,hb)
    
    clear E000001 E000002 E000003 E000004 E000005 E000006 E000007 E000008 E000009 E000010 E000011 E000012 E000013 E000014
    load(fullfile(datdir,flist(a).name))
    
    % description of ensembles (from appendix B in users guide)
    % E000001 : Beam velocity
    % E000002 : Instrument velocity
    % E000003 : Earth velocity (E,N,up,Q)
    % E000004 : Beam amplitude
    % E000005 : beam correlation
    % E000006 : Good beam pings
    % E000007 : good earth pings
    % E000008 : Ensemble data
    % E000009 : Ancillary data
    % E000010 : Bottom track data
    % E000011 : external NMEA string
    % E000012 : Profile engineering/setup data
    % E000013 : bottom track engineering/setup data
    % E000014 : System settings
    
    clear beam_vel inst_vel earth_vel amp corr Ngpings_beam EnsDat Nbins
    
    beam_vel=E000001;
    
    vel.BmVel0(:,a)=beam_vel(:,1);
    vel.BmVel1(:,a)=beam_vel(:,2);
    vel.BmVel2(:,a)=beam_vel(:,3);
    vel.BmVel3(:,a)=beam_vel(:,4);
    
    inst_vel=E000002;
    
    vel.X(:,a)=inst_vel(:,1);
    vel.Y(:,a)=inst_vel(:,2);
    vel.Z(:,a)=inst_vel(:,3);
    vel.Q(:,a)=inst_vel(:,4);
    
    clear earth_vel
    earth_vel=E000003;
    
    vel.u(:,a)=earth_vel(:,1);
    vel.v(:,a)=earth_vel(:,2);
    vel.w(:,a)=earth_vel(:,3);
    vel.Q(:,a)=earth_vel(:,4);
    
    % beam amplitude
    amp=E000004;
    vel.amp0(:,a)=amp(:,1);
    vel.amp1(:,a)=amp(:,2);
    vel.amp2(:,a)=amp(:,3);
    vel.amp3(:,a)=amp(:,4);
    
    % beam correlation
    corr=E000005;
    vel.corr0(:,a)=corr(:,1);
    vel.corr1(:,a)=corr(:,2);
    vel.corr2(:,a)=corr(:,3);
    vel.corr3(:,a)=corr(:,4);
    
    Ngpings_beam=E000006;
    
    % ensenmble data (includes date and time)
    clear yr mo dd hh mm ss dnum
    EnsDat=E000008;
    Nbins=EnsDat(2);
    yr=EnsDat(7);
    mo=EnsDat(8);
    dd=EnsDat(9);
    hh=EnsDat(10);
    mm=EnsDat(11);
    ss=EnsDat(12);
    dnum=datenum(yr,mo,dd,hh,mm,ss);
    datestr(dnum)   ;
    
    vel.dnum(a)=dnum;
    
    vel.ens_num(a)=EnsDat(1);
    
    % ancillary data (includes binsize, pitch and roll)
    clear Anc range_first binsize heading pitch roll temp
    Anc=E000009;
    range_firstbin=Anc(1); % range to 1st bin
    binsize=Anc(2); % bin size
    % make a depth vector from bin sizes
    vel.z=range_firstbin : binsize : range_firstbin+((Nbins-1)*binsize);
    vel.binsize=binsize;
    
    heading=Anc(5);
    pitch=Anc(6);
    roll=Anc(7);
    temp=Anc(8);
    
    vel.heading(a)=heading;
    vel.pitch(a)=pitch;
    vel.roll(a)=roll;
    
    % bottom-tracking data
    BTdat=E000010;
    bt_time_first=BTdat(1);
    bt_time_last=BTdat(2);
    
    vel.bt_range0(a)=BTdat(15);
    vel.bt_range1(a)=BTdat(16);
    vel.bt_range2(a)=BTdat(17);
    vel.bt_range3(a)=BTdat(18);
    
    vel.bt_status(a)=BTdat(12);
    
    vel.bt_u(a)=BTdat(47);
    vel.bt_v(a)=BTdat(48);
    vel.bt_w(a)=BTdat(49);
    
    
end

vel.datdir=datdir;
vel.flist=flist;
vel.MakeInfo=['Made ' datestr(now) ' w/ ' mfilename];

delete(hb)

return
%%