function calibrate(series,method,filters)
% function calibrate(SERIES,METHOD,FILTERS) calibrates SERIES using
% METHOD.  
% SERIES is a string which identifies which fieldname of the
% structure DATA to use.  Calibrated series are placed in the fields of the
% structure CAL and have the same name as in DATA.  
% 
% METHOD is generally a string which dictates the method of calibration.
% Current METHODS are one of:  {'T', 'TP', 'UC', 'UCP', 'C', 'AX', 'AY',
% 'TILT', 'AZ', 'P', 'FALLSPD', 'S', 'VOLTS'}
% Note: for tp, ucp, and uc, the method can be specified as a cell array
% consisting of METHOD={'tp','T0'} or {'uc','C2'} where the first string is
% the method, and the second string is the series that is associated with
% the series to be calibrated.  
% 
% FILTERS is an optional cell array with strings of the form:
%  filter is 'Axxx' where A is h,l,n for highpass, lowpass or notch filter
% and xxx is the cutoff frequency.  If A='n', then Axxx='n20-25' would notch
% out the frequencies between 20 and 25 Hz.
%
% FILTERS = {'h.05','l50','n20-22'} would highpass the data at 0.05 Hz, 
% lowpass the data at 50 Hz, and notch it between 20-22 Hz
%
% NOTE: series could be 'temp' if data.TEMP coef.TEMP and irep.TEMP all exist
% prior to calling calibrate.

global data head cal

series=upper(series);
eval(['inser=data.' series ';'])
eval(['ireps=head.irep.' series ';'])
filt_ord=4;

% for tp and ucp, the differentiated series may be calibrated when the
% undifferentiated signal has a different name:  
if iscell(method)
  m=lower(char(method(1)));
  from_series=upper(char(method(2)));  
else 
  m=lower(method);
end
% Need to do some special checks for tp and ucp
if strcmp(m,'tp') | strcmp(m,'ucp') 
if ~exist('from_series','var')
  from_series=series(1:length(series)-1);
end
  if ~any(strcmp(fieldnames(data),from_series))
    disp(['Error: data.' from_series ' does not exist.'])
    disp('To explicitly set the DC series which corresponds to an AC signal,')
    disp(['use calibrate(''TP_name'',{''TP'',''T_name''},{filters...})']) %  sara hickman restless
    error(' ')
  end
end
% Need to do some special checks for uc
if strcmp(m,'uc')
if ~exist('from_series','var')
  from_series='C';
end
  if ~any(strcmp(fieldnames(cal),from_series))
    disp(['Error: cal.' from_series ' does not exist.'])
    disp('To explicitly set the DC series which corresponds to an AC signal,')
    disp(['use calibrate(''UC_name'',{''UC'',''C_name''},{filters...})']) %  sara hickman restless
    error(' ')
  end
end
% First we should determine and apply the appropriate filters to the raw
% data.
if nargin==3
% if filters wasn't inside a {}, make it a cell.
  if ~iscell(filters);, filters=cellstr(filters);  end
  for j=1:length(filters)
    filts=lower(char(filters(j)));
    type=filts(1);
    if type=='l'
      % LOWPASS
      cutfreq=str2num(filts(2:length(filts)));
      [b,a]=butter(filt_ord,2*cutfreq/(head.slow_samp_rate*ireps));
    elseif type=='h'
      % HIGHPASS
      cutfreq=str2num(filts(2:length(filts)));
      [b,a]=butter(filt_ord,2*cutfreq/(head.slow_samp_rate*ireps),'high');
    elseif type=='n'
      % NOTCH
      position=find(filts=='-');
      cutfreq1=str2num(filts(2:(position-1)));
      cutfreq2=str2num(filts((position+1):length(filts)));
      [b,a]=butter(filt_ord,2*[cutfreq1 cutfreq2]/(head.slow_samp_rate*ireps),'stop') ;
    end
    if ~(strcmp(m,'fallspd')) % fallspd gets filtered later
      inser=filtfilt(b,a,inser);
    end
  end
end

if (strcmp(m,'t') | ...
      strcmp(m,'c') | ...
      strcmp(m,'ax') | ...
      strcmp(m,'ay') | ...
      strcmp(m,'poly') | ...
      strcmp(m,'az'))
eval(['cal.' series '=calibrate_poly(inser,head.coef.' series ');'])
elseif strcmp(m,'p') 
eval(['cal.' series '=calibrate_' m '(inser,head.coef.' ...
      series ');'])
elseif strcmp(m,'tilt')  
eval(['cal.' series '_TILT=calibrate_' m '(inser,head.coef.' ...
      series ');'])
eval(['head.irep.' series '_TILT=head.irep.' series ';']);
elseif strcmp(m,'fallspd')
%  Calibrate FALLSPD
  if exist('a','var')
    eval(['cal.FALLSPD=calibrate_' m '(inser,head.coef.' series ',ireps,a,b);'])
  else
    eval(['cal.FALLSPD=calibrate_' m '(inser,head.coef.' series ',ireps);'])
  end
elseif strcmp(m,'s') 
% calibrate PITOT or SHEAR
  eval(['cal.' series '=calibrate_' m '(inser,head.coef.' series ...
	',cal.FALLSPD);'])
elseif strcmp(m,'w') | strcmp(m,'wp') 
  error(['I can''t calibrate W this way -- use calibrate_w explicitly'])
elseif strcmp(m,'uc')
% calibrate MICROCONDUCTIVITY
  eval(['[cal.' series ', head.coef.' series ']=calibrate_uc(inser,cal.' from_series ');'])
elseif strcmp(m,'ucp') | strcmp(m,'tp')
% calibrate scalar derivitives such as UCP and TP
  eval(['cal.' series '=calibrate_tp(inser,head.coef.' series ...
	  ',data.' from_series ',head.coef.' from_series ',cal.FALLSPD);'])
elseif strcmp(m,'volts')
  eval(['cal.' series '=inser;'])
end