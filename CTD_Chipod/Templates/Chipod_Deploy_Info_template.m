%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% Chipod_Deploy_Info_template.m
%
% Deployment info for CTD chipods. For loading during chipod
% processing.
%
% Notes:
%
% (1) The sign of az_correction is not always consistent with the
% chipod deployment direction (some units are wired oppositely);
% the correct sign needs to be determined from aligning the chipod and 
% CTD (AlignChipodCTD.m in the processing script).
%
% (2) 
%
%---------------
% May 18, 2015 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

ChiInfo=struct();
ChiInfo.Project='Test';          % Description of project
ChiInfo.SNs={'SN1012','SN1002'}; % list of chipod SNs
ChiInfo.CastString='TestData';   % identifying string in CTD cast files

%~~~~~~~~~~~~~~~~~~~
% Example 'mini' chipod
%~~~~~~~~~~~~~~~~~~~
%%~~~~~~~~~~~~~~~~~~~
% SN 1012 
clear S
S.loggerSN='1012';   % logger serial number
S.pcaseSN='Ti88-3';  % pressure case SN
S.sensorSN='11-21D'; % sensor SN
S.InstDir='up';      % mounting direction (of sensor) on CTD
S.InstType='mini';   % Instrument type ('mini' or 'big')
S.isbig=0; %
S.az_correction=-1;  % See note above
S.suffix='A1012';    % suffix for chipod raw data filenames
S.cal.coef.T1P=0.097;% TP calibration coeff (time constant)
SN1012=S;clear S

%~~~~~~~~~~~~~~~~~~~
% Example 'big' chipod
%~~~~~~~~~~~~~~~~~~~
% SN 1002 
clear S
S.loggerSN='1002'; 
S.pcaseSN='1002';
S.sensorSN.T1='13-10D';
S.sensorSN.T2='11-23D';
S.InstDir.T1='up';
S.InstDir.T2='down';
S.InstType='big';
S.isbig=1;
S.cal.coef.T1P=0.105;
S.cal.coef.T2P=0.105;
S.suffix='A1002';
S.az_correction=-1; 
SN1002=S;clear S

ChiInfo.SN1012=SN1012;
ChiInfo.SN1002=SN1002;
ChiInfo.MakeInfo='Chipod_Deploy_Info_Template.m';
%%