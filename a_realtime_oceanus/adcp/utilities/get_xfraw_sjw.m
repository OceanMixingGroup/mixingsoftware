function data = get_xfraw_sjw(instclass, fullfilename, varargin)
% data = get_xfraw(instclass, fullfilename, varargin)
% 
% read all variables in raw fullfilename; 
% rotate into earth coordinates using gyro heading
%
% REQUIRES: (1) full path to raw fullfilename
%           (2) corresponding gbin files in ../../gbin/instname/time
%                                           ../../gbin/instname/best
%
% returns: data (original raw data fields)
%          data.enu                  measured vel. in east, north, up, errvel)
%          data.corr_dday            UTC time
%          data.lon, data.lat        position
%          data.heading              from gyro (or 'best')
%          data.pitch, data.roll     (if specified)
%
% options:       default            %      what
% --------    ------------               ---------------
% 'yearbase'  required for NB150   % 
% 'proc_yearbase'                  % 
% 'h_align'   required for NB150   % instrument transducer alignment
% 'beamangle' required for NB150   % transducer angle from vertical
% 'scalefactor'                    % multiplier for measured velocities
%                                  %      defaults to 1
% 'second_set', [0 or 1]           % if interleaved BB/NB which set?
%                                  % 0 (default) get BB   mode = 01
%                                  % 1           get NB   mode = 10
% 'badbeam' , 0                    % 0 for 4-beam solutions; 
%                                  %     1,2,3, or 4 to calculate 3-beam
%                                  %     solution with that beam ignored.
%                                  %
%                                  % different ways to specify data extracted
% 'irange',  [istart istop]        % range of indices to use
% 'ilist', [ index list]           % explicit index list overrides step
% 'step', [step]                   % use only every "step" index
% 'ends', [choose from 0,1,2,4]    % 0 (default - don't do it)
%                                  % 1: get only first profile
%                                  % 2: get first and last profile
%                                  % 3: not implimented
%                                  % 4: get first and last pair of profiles
%                                  % NOTE: use of 'ends' overrides irange, step,
%
% Known bug: first and last point requested might not have navigation or heading
% suggest: use 'ends'=4 instead of 'ends'=2
% 

cfg.proc_yearbase  = []; 
cfg.yearbase  = []; 
cfg.h_align   = [];
cfg.beamangle = [];
cfg.irange    = [];
cfg.ilist     = [];
cfg.step      = [];
cfg.ends      = []; 
cfg.second_set = 0;
cfg.badbeam = 0;
cfg.scalefactor=1;
cfg.h_corrang = [];

cfg = fillstruct(cfg, varargin);

if isa(instclass, 'nb')
   if isempty(cfg.beamangle)
      error('must set beam angle for NB instrument\n')
   end
   if isempty(cfg.h_align)
      error('must set heading alignment for NB instrument\n')
   end
   if isempty(cfg.yearbase)
      error('must set yearbase for NB instrument\n')
   end
end

if isstr(fullfilename) && ~exist(fullfilename, 'file')
   fprintf('%s does not exist or is not a file or is not a string\n', ...
           fullfilename)
   return
end

if isemptys(cfg.proc_yearbase)
    cfg.proc_yearbase = cfg.yearbase;
    if isemptys(cfg.yearbase)
%         fprintf('yearbase and proc_yearbase unspecified : using first date\n')
    else
%         fprintf('proc_yearbase unspecified: setting to same as yearbase\n')
    end
end


if isa(instclass, 'os') 
   data = read(instclass, fullfilename, 'vars', 'all',...
               'proc_yearbase', cfg.proc_yearbase,...
               'yearbase', cfg.yearbase,...
               'irange', cfg.irange,...
               'ilist',  cfg.ilist,...
               'second_set', cfg.second_set,...
               'irange', cfg.irange,...
               'ends',    cfg.ends);
else
   data = read(instclass, fullfilename, 'vars', 'all',...
               'proc_yearbase', cfg.proc_yearbase,...
               'yearbase', cfg.yearbase,...
               'irange', cfg.irange,...
               'ilist',  cfg.ilist,...
               'ends',    cfg.ends);
end   

if isempty(cfg.h_align)
   cfg.h_align = data.config.head_align;
end

if isempty(cfg.beamangle)
   cfg.beamangle = data.config.beamangle;
end

if isempty(cfg.scalefactor)
    cfg.scalefactor=1;
end

data.vel = data.vel*cfg.scalefactor;


[ppath, rawfilebase] = fileparts(fullfilename);
[rawdir, instname] =  fileparts(ppath);
uhdas_dir = fileparts(rawdir);

gbindirbase = fullfile(uhdas_dir, 'gbin', instname);

timefile = sprintf('%s.tim.gbin', rawfilebase);
bestfile = sprintf('%s.best.gbin', rawfilebase);

[timedata, timestruct] = read_bin(fullfile(gbindirbase, 'time', timefile));
if timestruct.fid > 0
    fclose(timestruct.fid);
    %use messagename to figure out column names
    if strcmp(timestruct.messagename, 'pingtime')
        best_loggerdday_name = 'unix_dday';
        best_utcdday_name = 'dday';
    else  % assuming 'besttime'
        best_loggerdday_name = 'logger_dday';
        best_utcdday_name = 'bestdday';
    end
end


[bestdata, beststruct] = read_bin(fullfile(gbindirbase, 'time', bestfile));
if beststruct.fid > 0
    fclose(beststruct.fid);
end







% trim inputs to return longest available data, eg. if 
% gbins were made 1 minute ago but raw file is 'live'
logrfile = sprintf('%s.raw.log.bin', rawfilebase);
[ldata, lstruct]=read_bin(fullfile(ppath,logrfile));
if lstruct.fid > 0
    fclose(lstruct.fid);
end

ldata = ldata(:,data.info.ilist);
adcp_unixdday_sec100 = round(100*86400*ldata(r_row(lstruct, 'unix_dday'),:));
gbin_unixdday_sec100 = ...
      round(100*86400*timedata(...
          r_row(timestruct, best_loggerdday_name),:));

if adcp_unixdday_sec100(end) > gbin_unixdday_sec100(end)
   goodi = find(adcp_unixdday_sec100 <= gbin_unixdday_sec100(end));
   data = cutadcp(data, goodi);
   ldata = ldata(:,goodi);
end
% back to original code

timedata = timedata(:,data.info.ilist);
bestdata = bestdata(:,data.info.ilist);

data.corr_dday = timedata(r_row(timestruct,best_utcdday_name),:);
if length(data.corr_dday) ~= length(data.dday)
   error('%s: time gbin data length does not match raw data\n', rawfilebase);
end

fnames = beststruct.rows;
for fnamei = 1:length(fnames)
   fname = fnames{fnamei};
   fval =  bestdata(r_row(beststruct, fname),:);
   if length(fval) ~= length(data.dday)
      error('%s: best gbin data length does not match raw data\n', rawfilebase);
   end
   data = setfield(data, fname, fval);
end

% navigation field
lon_row = find(strcmp(beststruct.rows, 'lon'));
lat_row = find(strcmp(beststruct.rows, 'lat'));

nav.txy1 = [data.corr_dday ;bestdata([lon_row lat_row],:)];
nav.txy2 = nav.txy1; %NOT GOOD -- should separate these






% (sjw 11/11/14): adding in code that gets the ashtech correction
% When the ashtech is working, we want to use the ashtech's header NOT the
% gyro's heading (which comes from bestdata). (Note: it's called "best"
% because it is more reliable, but it is NOT as accurate.) So, we want to
% (1) load in the ashtech data, (2) check to see if it's reacquisition flag
% is good=0 and not bad=1, (3) develop a correction factor between the gyro
% and the ashtech by looking at the statistics of the difference between
% the two headings, (4) correct data.heading with the best possible
% heading.
adufile  = sprintf('%s.adu.gbin', rawfilebase);

if exist(fullfile(gbindirbase, 'ashtech', adufile))

    [adudata, adustruct] = read_bin(fullfile(gbindirbase, 'ashtech', adufile));
    if adustruct.fid > 0
        fclose(adustruct.fid);
    end
    % find the index of the good data
    ash.goodind = find(adudata(7,data.info.ilist) == 0); % reacq=adudata(7,:) reads 1 for bad data and 0 for good data
    % find a correction factor for the gyro data
    if length(ash.goodind) >= adustruct.irange(2)*0.1; % want at least 10% of the ashtech data to be good in order to apply the correction
        ash.error = adudata(2,ash.goodind) - bestdata(3,ash.goodind); % adudata(2,:)=ashtech heading, bestdata(3,:)=gyro heading
        ash.errorcheck = find(abs(ash.error) < 10);   % sometimes bad points get through that should not be included in the mean. using 10 degrees as a threshold
        ash.errorgood = ash.error(ash.errorcheck);
        ash.errormean = nanmean(ash.errorgood); % *** this is taking a mean over the 2-hour datafile to create a correction factor. for eq14 this is good, may need to change in the future to something that changes on a more fast time scale
        data.heading = bestdata(3,:) + ash.errormean; % apply the correction to the heading in the data structure t
        disp(['calculated a header correction angle: errormean = ' num2str(ash.errormean)])
    elseif isfield(cfg,'h_corrang') % if the ashtech is bad AND h_corrang is defined in set_currents_oceanus
        disp(['using a default header correction angle of ' num2str(cfg.h_corrang)])
        data.heading = data.heading + cfg.h_corrang; % the heading data just stays as the gyro heading
    else % if the ashtech is bad AND h_corrang is NOT defined in set_currents_oceanus
        disp('not correcting the gyro heading with the ashtech heading')
        data.heading = data.heading;
    end
    
elseif isfield(cfg,'h_corrang') % if the ashtech is bad AND h_corrang is defined in set_currents_oceanus
    disp(['using a default header correction angle of ' num2str(cfg.h_corrang)])
    data.heading = data.heading + cfg.h_corrang; % the heading data just stays as the gyro heading
else % if the ashtech is bad AND h_corrang is NOT defined in set_currents_oceanus
    disp('not correcting the gyro heading with the ashtech heading')
    data.heading = data.heading;
end
    

% end (sjw 11/11/14 changes)






%% 2006/10/28
secpc_row = find(strcmp(timestruct.rows, 'sec_pc_minus_utc'));
nav.sec_pc_minus_utc = timedata(secpc_row,:);


data.nav = nav;

[data.enu data.xyze] = ....
    beam_enu(instclass, data.vel,...
             cfg.h_align + data.heading,...
             0*data.heading, 0*data.heading, ...
             'error', 1,...
             'convex', data.config.convex,...
             'badbeam', cfg.badbeam,...
             'beamangle', cfg.beamangle);



if (isfield(data, 'bt'))
   data.bt.enu = ...
       beam_enu(instclass, data.bt.vel,...
                cfg.h_align + data.heading,...
                0*data.heading, 0*data.heading, ...
                'error', 1,...
                'convex', data.config.convex,...
                'badbeam', cfg.badbeam,...
                'beamangle', cfg.beamangle);
end

