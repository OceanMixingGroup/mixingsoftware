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
%
%---------------
% May 18, 2015 - A.Pickering - apickering@coas.oregonstate.edu
% 06/12/16 - AP - Update to newer format
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

ChiInfo=struct();
ChiInfo.Project='I08';           % Project name
ChiInfo.SNs={'SN1013','SN1002'}; % List of chipod SNs
ChiInfo.CastString='I08S';       % Identifying string in CTD cast files

%~~~~~~~~~~~~~~~~~~~
% Example 'mini' chipod
%~~~~~~~~~~~~~~~~~~~

%%~~~~~~~~~~~~~~~~~~~
% SN 1013 
clear S SN
SN='1013';
S.loggerSN=SN;       % logger serial number
S.pcaseSN='Ti44-11'; % pressure case SN
S.sensorSN='14-34D'; % sensor SN
S.InstDir.T1='up';      % mounting direction (of sensor) on CTD
S.InstType='mini';   % Instrument type ('mini' or 'big')
S.isbig=0;           % 1 for 'big' chipods
S.az_correction=-1;  % See note above
S.suffix='mlg';      % suffix for chipod raw data filenames
S.cal.coef.T1P=0.097;% TP calibration coeff (time constant)
ChiInfo.(['SN' SN])=S;clear S


%~~~~~~~~~~~~~~~~~~~
% Example 'big' chipod
%~~~~~~~~~~~~~~~~~~~
% SN 1002 
clear S SN
SN='1002';
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
ChiInfo.(['SN' SN])=S;clear S

% ***
ChiInfo.MakeInfo='Chipod_Deploy_Info_I08.m';
%%
