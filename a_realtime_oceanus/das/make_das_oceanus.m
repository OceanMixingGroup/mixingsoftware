% make_das_oceanus
%
% Process new Oceanus DAS system. This function reads in the raw DAS data
% from the ship's computer, calls all of the "read" functions to convert
% the raw data to matlab, and saves .mat files for each instrument.
%
% Run combine_das_oceanus to put all of the DAS data into a single .mat
% file.
%
% Originally by Sasha Perlin
% Updated and commented by Sally Warner



clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set paths
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% path to the raw data
% datadir='\\ttwo\ttwo_cruises\current\das\';
% datadir  = '/Volumes/ttwo_cruises/current/das/';
datadir = '~/data/yq14/data/das/';

% path to where the processed data should be saved
% savedir='e:\work\Alaska12\das\';
savedir='~/data/yq14/processed/das/';

% startnum
% on what day do you want to start processing? This is the number of the
% day within the das folder on ttwo. (This is necessary because there might
% be folders for days that you do not need to analyze.)
startday = 7;

% cruise id
cruise_id='yq14';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% loop through all instruments to process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

strc={'fluorometer_flowthrough','fluorometer';
    'gnss_adu5_bow','ashtech';
    'gyrocompass','gyro';
    'metstation_03stb','met';
    'metstation_bow','met';
    'radiometer_metmast','rad';
    'raingauge_metmast_1','rain';
    'thermometer_bow','temp_bow';
    'thermometer_fwdintake','temp_int';
    'transmissometer_flowthrough','trans';
    'tsg_flowthrough','tsg';
    'truewind_bow_adu5','wind'};
warning off    
dd1=dir([datadir '2*']);
for ii=startday:length(dd1)
    mkdir([savedir dd1(ii).name])
    disp(dd1(ii).name)
    for nn=1:size(strc,1)
        % read file
        dd2=dir([datadir dd1(ii).name filesep 'csv' filesep char(strc(nn,1)) '.*']);
        for jj=1:length(dd2)
            eval(['out=read_' char(strc(nn,1)) '([''' ...
                datadir dd1(ii).name filesep 'csv' filesep dd2(jj).name ''']);']);
            flds=fields(out);flds=setdiff(flds,'readme');
            if jj==1;
                data.(char(strc(nn,2)))=out;
                data.(char(strc(nn,2))).readme=out.readme;
            else
                for kk=1:length(flds)
                    data.(char(strc(nn,2))).(char(flds(kk)))=...
                        [data.(char(strc(nn,2))).(char(flds(kk)));out.(char(flds(kk)))];
                end
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % save .mat file for each instrument
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if isfield(out,'readme')
            eval([char(strc(nn,2)) '=data.(char(strc(nn,2)));']);
            disp(char(strc(nn,1)));
            save([savedir dd1(ii).name filesep char(strc(nn,1)) '_' dd1(ii).name],char(strc(nn,2)))
            clear data
        end
    end
end

