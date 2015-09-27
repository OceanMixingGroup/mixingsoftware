%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Chipod_Deploy_Info_template.m
%
% Deployment info for CTD chipods. For loading during chipod
% processing.
%
% Note that the sign of az_correction is not always consistent with the
% chipod deployment direction; the correct sign can be determined from
% aligning the chipod and CTD (AlignChipodCTD.m in the processing script).
%
% May 18, 2015 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

ChiInfo=struct();
ChiInfo.Project='Test';

%~~~~~~~~~~~~~~~~~~~
% Example 'mini' chipod
%~~~~~~~~~~~~~~~~~~~
%%~~~~~~~~~~~~~~~~~~~
% SN 1012 
SN1012.loggerSN='1012'; % logger serial number
SN1012.pcaseSN='Ti88-3';
SN1012.sensorSN='11-21D';
SN1012.InstDir='up';
SN1012.InstType='mini';
SN1012.az_correction=-1; %
SN1012.suffix='A1012'; % suffix for data filenames
SN1012.isbig=0; %
SN1012.cal.coef.T1P=0.097;

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


ChiInfo.SN1012=SN1012;
ChiInfo.SN1002=SN1002;
ChiInfo.MakeInfo='Chipod_Deploy_Info_Template.m';
%%