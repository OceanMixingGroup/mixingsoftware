%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Chipod_Deploy_Info_template.m
%
% Deployment info for CTD chipods. For loading during chipod
% processing.
%
% ** change InstDir to InstDir.T1,T2 etc. to make compatible with big
% chipods ? **
%
% May 18, 2015 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

ChiInfo=struct();
ChiInfo.Project='TTIDE';

%~~~~~~~~~~~~~~~~~~~
% Example 'mini' chipod
%~~~~~~~~~~~~~~~~~~~
% SN 102
SN102.loggerSN='102'; % logger serial number
SN102.pcaseSN='Ti88-4;';
SN102.sensorSN='11-15C';
SN102.InstDir='up';
SN102.InstType='mini';
SN102.az_correction=-1; % -1 if the Ti case is pointed up
SN102.suffix='A0102';
SN102.isbig=0;
SN102.cal.coef.T1P=0.097;

%~~~~~~~~~~~~~~~~~~~
% Example 'big' chipod
%~~~~~~~~~~~~~~~~~~~
% SN 1002 
SN1002.loggerSN='1002'; % logger serial number
SN1002.pcaseSN='1002';
SN1002.sensorSN.T1='13-10D';
SN1002.sensorSN.T2='11-23D';
SN1002.InstDir.T1='up';
SN1002.InstDir.T2='down';
SN102.InstType='big';
SN1002.cal.coef.T1P=0.105;
SN1002.cal.coef.T2P=0.105;
SN1002.suffix='A1002';
SN1002.isbig=1;
SN1002.az_correction=-1; % check this ?


ChiInfo.SN102=SN102;
ChiInfo.SN1002=SN1002;
ChiInfo.MakeInfo='Chipod_Deploy_Info_TTIDE.m';
%%