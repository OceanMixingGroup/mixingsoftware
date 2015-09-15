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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set paths
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% path to the raw data
% datadir='\\ttwo\ttwo_cruises\current\das\';
% datadir  = '/Volumes/ttwo_cruises/current/das/';
% datadir = '~/data/yq14/data/das/';
% datadir = '~/GDrive/data/eq14/testing_oceanus_met_data_oct2014/raw/das/';
% datadir = '/Volumes/tfour_cruises/current/das/';
datadir = [localdir 'raw' filesep];

% path to where the processed data should be saved
% savedir='e:\work\Alaska12\das\';
% savedir='~/data/yq14/processed/das/';
% savedir = '~/GDrive/data/eq14/testing_oceanus_met_data_oct2014/processed/das/';
savedir = [localdir 'processed' filesep];

% startnum
% on what day do you want to start processing? This is the number of the
% day within the das folder on ttwo (now tfour). (This is necessary because there might
% be folders for days that you do not need to analyze.)

% cruise id
cruise_id='eq14';


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% loop through all instruments to process
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

strc1={...
% % %     'anemometer_metmast','anemometer';  % not needed because it should be processed first using other data. Use the truewind products
% % %     'echosounder_well','echosounder';
  'fluorometer_flowthrough','fluorometer';
    'gnss_adu5_bow','ashtech';
    'gnss_bow_gps','gps';
    'gyrocompass','gyro';
    'metstation_03stb','met2';
    'metstation_bow','met';
    'oxygen_mll_flowthrough','oxygen';
    'radiometer_metmast_par','par';
    'radiometer_metmast','rad';
    'raingauge_metmast_1','rain';
   'thermometer_fwdintake','temp_int';
   'thermometer_hull','temp_hull';         % used to be
                                           % "thermometer_bow"
   'transmissometer_flowthrough','trans';
   'truewind_metmast_adu5','wind_adu';         % used to be "truewind_bow_adu5". Uses the same anemometer as truewind_metmast_gyro_gps, but then processes the wind product using ship's pitch and roll
  'truewind_metmast_gyro_gps','wind_gyro';     % used to be
                                                 % "truewind_bow_gyro_bowgps". Uses
                                                 % the same
                                                 % anemometer as
                                                 % truewind_metmast_adu5,
                                                 % but then
                                                 % processes the
                                                 % wind product
                                                 % using ship's gps
                                                 % and gyro %
    'tsg_flowthrough','tsg'
     };
 
 
 strc2={...
% % %     'anemometer_metmast','anemometer';  % not needed because it should be processed first using other data. Use the truewind products
% % %     'echosounder_well','echosounder';
  'fluorometer_flowthrough','fluorometer';
    'gnss_adu5_bow','ashtech';
    'gnss_bow_gps','gps';
    'gyrocompass','gyro';
    'metstation_03stb','met2';
    'metstation_bow','met';
    'oxygen_mll_flowthrough','oxygen';
    'radiometer_03port','radport';
    'radiometer_metmast_par','par';
    'radiometer_metmast','rad';
    'raingauge_metmast_1','rain';
   'thermometer_fwdintake','temp_int';
   'thermometer_hull','temp_hull';         % used to be
                                           % "thermometer_bow"
   'transmissometer_flowthrough','trans';
   'truewind_metmast_adu5','wind_adu';         % used to be "truewind_bow_adu5". Uses the same anemometer as truewind_metmast_gyro_gps, but then processes the wind product using ship's pitch and roll
  'truewind_metmast_gyro_gps','wind_gyro';     % used to be
                                                 % "truewind_bow_gyro_bowgps". Uses
                                                 % the same
                                                 % anemometer as
                                                 % truewind_metmast_adu5,
                                                 % but then
                                                 % processes the
                                                 % wind product
                                                 % using ship's gps
                                                 % and gyro %
    'tsg_flowthrough','tsg'
     };
 
missing_mats.par = struct('readme',[],'time',[],'parVolts',[]);
missing_mats.rad = struct('readme',[],'time',[],'LW',[],'SW',[]);
missing_mats.rain = struct('readme',[],'time',[],'Volt',[]);


warning off 
dd1=dir([datadir '2*']);
for ii=startday:length(dd1);
    mkdir([savedir dd1(ii).name])
    disp(dd1(ii).name)
    if datenum(dd1(ii).name) < 735914 % no rad_03port before 11-11-14
        strc = strc1;
    else
        strc = strc2;
    end
    
%     strc = {'radiometer_03port','radport'};
    
    for nn=1:size(strc,1)
        % read file
        dd2=dir([datadir dd1(ii).name filesep char(strc(nn,1)) '.*']);
        if length(dd2) == 0;
           data.(char(strc(nn,2))) = missing_mats.(char(strc(nn,2)));
           flds = fields(data.(char(strc(nn,2))));
           data.(char(strc(nn,2))).readme = char('This data file was missing and this file contains NaNs to serve as placeholders for', (char(strc(nn,1))));
           data.(char(strc(nn,2))).time = out.time;
           for kk = 3:length(flds)
               data.(char(strc(nn,2))).(char(flds(kk))) = ...
                   NaN(size(out.time));
           end
        else   
            for jj=1:length(dd2)
               eval(['out=read_' char(strc(nn,1)) '([''' ...
                     datadir dd1(ii).name filesep dd2(jj).name ''']);']);
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
           end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % save .mat file for each instrument
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if isfield(out,'readme')
            eval([char(strc(nn,2)) '=data.(char(strc(nn,2)));']);
            disp(char(strc(nn,1)));
            save([savedir dd1(ii).name filesep char(strc(nn,1)) '_' ...
                  dd1(ii).name],char(strc(nn,2)))
            %         clear data
            %        save([wdmycloud 'processed/' dd1(ii).name filesep char(strc(nn,1)) ... '_' dd1(ii).name],char(strc(nn,2)));
        end
    end
end

