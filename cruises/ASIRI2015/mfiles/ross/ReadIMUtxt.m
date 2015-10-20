%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Read the ROSSIMUinfo.txt file into a matlab structure
%
%
% 08/28/15 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%
clear ; close all
%fname='/Volumes/scienceparty_share/ROSS/ROSSIMUinfo.txt'
fname='/Volumes/scienceparty_share/ROSS/5amROSSIMUinfo.txt'

%
%D=ReadRossIMU(fname,1,'inf')
[VarName1,xacc,yacc,zacc,xgyro,ygyro,zgyro,xmag,ymag,zmag]=ReadRossIMU(fname)%,1013643-45000,1013643-15000);

%% parse timestamps
dnum=nan*ones(1,length(VarName1));

for wht=1:length(VarName1)
    %
    tmp=VarName1{wht};
    yyyy=str2num(tmp(1:4));
    MM=str2num(tmp(6:7));
    dd=str2num(tmp(9:10));
    HH=str2num(tmp(12:13));
    mm=str2num(tmp(15:16));
    ss=str2num(tmp(18:19));
    
    dnum(wht)=datenum(yyyy,MM,dd,HH,mm,ss);
    
    %
end

%%
figure(1);clf
plot(dnum,atan2d(ymag,xmag))
%plot(dnum(2:2:end),xacc(2:2:end))
%plot(dnum
datetick('x')
grid on
xlabel(['Time on ' datestr(floor(dnum(1)))])
%%
imu=struct()
imu.dnum2=dnum(1:2:end);
imu.xacc=xacc(1:2:end);
imu.yacc=yacc(1:2:end);
imu.zacc=zacc(1:2:end);

imu.dnum=dnum;
imu.xmag=xmag;
imu.ymag=ymag;
imu.zmag=zmag;

%imu.xmag=xmag

imu.MakeInfo=['Made ' datestr(now) ' w/ ReadIMUtxt.m']
imu.source=fname;
save('/Volumes/scienceparty_share/ROSS/ROSSIMUinfo.mat','imu')

%%