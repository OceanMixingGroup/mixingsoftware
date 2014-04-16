function inser=filter_series(inser,sample_rate,filters,order)
% function outseries=filter_series(inseries,sample_rate,filters) filters INSERIES which
% is sampled at SAMPLE_RATE at frequencis given by FILTERS.
% The cell array {filters} = {'h.05','l50','n20-21'} would highpass
% the data at 0.05 Hz, lowpass the data at 50 Hz, and notch it at 20-21 Hz
% an option filter order can be added; 8 is the default

% First we should determine and apply the appropriate filters to the raw
% data.

% if filters wasn't inside a {}, make it a cell.
if nargin<4
   order=8;
end
   
if ~iscell(filters);, filters=cellstr(filters);  end
for j=1:length(filters)
  filts=lower(char(filters(j)));
  type=filts(1);
  if type=='l'
    % LOWPASS
    cutfreq=str2num(filts(2:length(filts)));
    [b,a]=butter(order,2*cutfreq/(sample_rate));
  elseif type=='h'
    % HIGHPASS
    cutfreq=str2num(filts(2:length(filts)));
    [b,a]=butter(order,2*cutfreq/(sample_rate),'high');
  elseif type=='n'
    % NOTCH
    position=find(filts=='-');
    cutfreq1=str2num(filts(2:(position-1)));
    cutfreq2=str2num(filts((position+1):length(filts)));
    [b,a]=butter(order,2*[cutfreq1 cutfreq2]/(sample_rate),'stop') ;
  end
    inser=filtfilt(b,a,inser);
end

