
function [avg]=quick_avg_noadcp(data,head)
% % % %   called from make_chipod_avg file

%calibration of T1 T2 and P sensor
cal.T1=calibrate_polynomial(data.T1,head.coef.T1);
cal.T2=calibrate_polynomial(data.T2,head.coef.T2);
cal.P=calibrate_polynomial(data.P,head.coef.P);

%%%%%%%%%%%%%%%%%%%%%%%
%calibration of X and Y tilts in degrees from accelerometer data
cal.AX = calibrate_tilt(data.AX,head.coef.AX);
cal.AY = calibrate_tilt(data.AY,head.coef.AY);

%calibration of AZ in g (acceleration) 
cal.AZ = calibrate_polynomial(data.AZ,head.coef.AZ);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%calibration of compass data to degrees ..note you may need to add magnetic
%declination to further compensate the earth's mag field. See Johannes note
cal.CMP = data.CMP/10;

%chose timebins in yy,mm,dd,HH,MM,SS format
%example 1 hr average set datenum(0,0,0,0,59,59.9)
%example 1 min average set datenum(0,0,0,0,0,59.9)
timebins=data.datenum(1):datenum(0,0,0,0,59,59.9):data.datenum(end);

[avg.time,Vx,nX]=bindata1d(timebins,data.datenum,data.datenum);
[avg.W,Vx,nX]=bindata1d(timebins,data.datenum(1:2:end),data.W);
% [Mx,avg.WP,nX]=bindata1d(timebins,data.datenum(1:2:end),data.WP); 
%WP no longer used in chipods

[avg.T1,Vx,nX]=bindata1d(timebins,data.datenum(1:2:end),cal.T1);
[avg.T2,Vx,nX]=bindata1d(timebins,data.datenum(1:2:end),cal.T2);
[Mx,avg.T1P,nX]=bindata1d(timebins,data.datenum,data.T1P); %variance
[Mx,avg.T2P,nX]=bindata1d(timebins,data.datenum,data.T2P); %variance
[avg.P,Vx,nX]=bindata1d(timebins,data.datenum(1:2:end),cal.P);
[avg.AX,Vx,nX]=bindata1d(timebins,data.datenum(1:2:end),cal.AX);
[avg.AY,Vx,nX]=bindata1d(timebins,data.datenum(1:2:end),cal.AY);
[avg.AZ,Vx,nX]=bindata1d(timebins,data.datenum(1:2:end),cal.AZ);
[avg.CMP,Vx,nX]=bindata1d(timebins,data.datenum(1:20:end),cal.CMP);
[avg.V,Vx,nX]=bindata1d(timebins,data.datenum(1:20:end),data.VD);
[avg.Va,Vx,nX]=bindata1d(timebins,data.datenum(1:20:end),data.MK6);
end
