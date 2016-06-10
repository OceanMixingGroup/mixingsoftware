function MakeTableChiDeploy(ChiInfo)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% MakeTableChiDeploy.m
%
% Make a summary table of chipods deployed during a cruise. Makes a latex
% table that can be copied into notes.
%
% Uses data from the 'Chipod_Deploy_Info_XXXX.m' file
%
%-------------
% 06/10/16 - A.Pickering - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

%clear ; close all

%~~~
%Chipod_Deploy_Info_I08
%~~~

Nsn=length(ChiInfo.SNs)
and=' & '
lend=' \\ '
clc
disp('\begin{table}[htdp]')
disp(['\caption{$\chi$pod Deployment Info for ' ChiInfo.Project '}'])
disp('\begin{center}')
disp('\begin{tabular}{|c|c|c|c|}')

disp('\hline')
disp(['SN' and 'Type' and 'Dir' and 'Sensor' lend])
disp('\hline')
disp('\hline')

for iSN=1:Nsn
    whSN=ChiInfo.SNs{iSN};
    disp([whSN and ChiInfo.(whSN).InstType and ChiInfo.(whSN).InstDir and ChiInfo.(whSN).sensorSN lend])    
end

disp('\hline')
disp('\end{tabular}')
disp('\end{center}')
disp('\label{chidepinfo}')
disp('\end{table}')

%%