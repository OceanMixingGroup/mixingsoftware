% combine_das_oceanus
%
% Combine all of the DAS data from Oceanus. make_das_oceanus must be run
% first to process all of the raw data into .mat files. This combines
% everything into one .mat file.
%
% originally written by Sasha Perlin
% updated by Sally Warner, January 2014



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set paths
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% set the path to the processed DAS data (where it is saved by
% make_das_oceanus.

% matdir='e:\work\Alaska12\das\';
% matdir='~/data/yq14/processed/das/';
% matdir = '~/GDrive/data/eq14/testing_oceanus_met_data_oct2014/processed/das/';
matdir = [localdir 'processed' filesep];

% crusie id
% cruise_id='yq14';
cruise_id='eq14';

% list all of the days where data has been collected
dd1=dir([matdir '2*']);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% make "fake" data of NaNs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% during eq14, on 11-11-2014, a new instrument was added to the das stream.
% metstation_03stb did not exist during the first 5 days. Make a fake
% dataset full of nans so that this code runs correctly with the least
% amount of difficulty
for ii = 1:5
    load([matdir '2014-11-11' filesep 'radiometer_03port_2014-11-11.mat'])
    radportfake.readme = radport.readme;
    load([matdir dd1(ii).name filesep 'fluorometer_flowthrough_' dd1(ii).name '.mat'])
    radportfake.time = fluorometer.time;
    radportfake.LW = NaN*radportfake.time;
    radportfake.SW = NaN*radportfake.time;
    clear radport
    radport = radportfake;
    save([matdir dd1(ii).name filesep 'radiometer_03port_' dd1(ii).name '.mat'],'radport')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% loop through all data and combine
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for ii=1:length(dd1)
    disp(dd1(ii).name)
    if ii==1
        dd2=dir([matdir dd1(ii).name filesep '*.mat']);
        for jj=1:length(dd2)
            ff{jj}=load([matdir dd1(ii).name filesep dd2(jj).name]);
            var1(jj)=fields(ff{jj});
            var2(jj).fl=fields(ff{jj}.(char(var1(jj))));
            var2(jj).fl=setdiff(var2(jj).fl,'readme');
        end
%     elseif ii == 6
%         dd2 = dir([matdir dd1(ii).name filesep '*.mat']);
%         for jj = 1:length(dd2)
%             ff{jj} = load([matdir dd1(ii).name filesep ...
%                           dd2(jj).name]);
%             var1(jj) = fields(ff{jj});
%             var2(jj).fl = fields(ff{jj}.(char(var1(jj))));
%             var2(jj).fl = setdiff(var2(jj).fl,'readme');
%         end
     else   
        for jj=1:length(dd2)
            fln=dir([matdir dd1(ii).name filesep dd2(jj).name(1:end-12) '*']);
            tmp=load([matdir dd1(ii).name filesep fln.name]);
            for kk=1:length(var2(jj).fl)
                ff{jj}.(char(var1(jj))).(char(var2(jj).fl(kk))) = ...
                    [ff{jj}.(char(var1(jj))).(char(var2(jj).fl(kk))); ...
                    tmp.(char(var1(jj))).(char(var2(jj).fl(kk)))];
            end
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % save a combined file
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % saved in the save directory as all of the individual .mat files
    if ii==length(dd1)
        for jj=1:length(dd2)
            fld=fields(ff{jj});
            eval([char(fld) '=ff{jj}.(char(fld));']);
            save([matdir dd2(jj).name(1:end-14) cruise_id], ...
                 char(fld))
            %            save([wdmycloud 'processed/' dd2(jj).name(1:end-14) cruise_id],char(fld));
        end
    end
    
    
end
