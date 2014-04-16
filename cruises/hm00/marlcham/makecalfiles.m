
% this script calibrates all teh data and stored it in a
% calibration directory...
[st,i]=dbstack;
thisfile=st.name
q.script.prefix='hm00';
q.script.pathname='\\galiano\datad\home\marlin\marlin\';

d=dir([q.script.pathname q.script.prefix '*']);

load \\galiano\data\data\hm00\marlin\velocity_eq
load \\galiano\data\data\hm00\marlin\sum_tcp

q.script.caldir = '\\galiano\data\data\hm00\marlin\caltest\'

failed=[];
for i=1:length(d)
%for i=1:20
  if strcmp(d(i).name(1:4),q.script.prefix)
    d(i).name
    num = str2num([d(i).name(end-4) d(i).name(end-2:end)]);
    q.script.num=num;  % make sure to input this!
%    try
      [data,head]=raw_load(q);
      cali_hm00_jmk;
      % append a documentation string to it....
      cal.doc = {['JMK: ' date ' made using makecalfiles.m which calls' ...
		  ' cali_hm00_jmk.m '],
		 thisfile};	       
      % save it...
      calname = sprintf('%s%s%04d.mat',q.script.caldir,...
			q.script.prefix,q.script.num)
      save(calname,'cal','head');
 %   catch;
  %    failed = [failed num];
   %   laste = lasterr;
   % end; % try-catch;;;
  end;% if strcmp(d.name...
end; % for...