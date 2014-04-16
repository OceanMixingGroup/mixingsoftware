function y=gappy_filter(b,a,x,maxinterplen,fillgaps,doplot);
% function y=gappy_filter(b,a,x,maxinterplen);
% filters x but does skips over gaps smaller than maxinterplen.  
%
% Smooths x, but does not do so across large gaps, denoted by NaNs.
% The maximum gap that will be filtered across is given by
% maxinterplen, which defaults to 0.  The data in all gaps is
% returned as NaN as it was in the original data.  
% 
% The function uses filtfilt on the good data, so the response
% funtion of the filter is squared...
%
% y=gappy_filter(b,a,x,maxinterplen,fillgaps);
% will fill the gaps that are smaller than maxinterplen with the
% linearly interpolated data.
%
% If x is a matrix, then the filtering is applied columnwise...

% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:45 $ $Author: aperlin $	
% Originally J. Klymak, March 2003
  
if nargin<6
  doplot=[];
end;
if isempty(doplot)
  doplot=0;
end;
if nargin<5
  fillgaps = [];
end;
if isempty(fillgaps)
  fillgaps = 0;
end;


if length(a)==1 & length(b)==1
  y = x;
  return;
end;

if size(x,2)>1 & size(x,1)>1
  % loop over columns...
  y=x;
  for i=1:size(x,2)
    y(:,i) = gappy_filter(b,a,x(:,i),maxinterplen,fillgaps);
  end;
  return;
end;

x=x(:); % convert rows to columns;
y=NaN*x;    

if length(b)==1 & length(a) == 1
  return;
end;

if nargin<4
  maxinterplen = [];
end;
if isempty(maxinterplen)
  maxinterplen=0;
end;

t = 1:length(x);
t=t(:);
in = find(isinf(x));
x(in) = NaN;
good =find(~isnan(x));
dt = diff(t(good));
% get gaps that are too large 
bad = find(dt>(maxinterplen+1));
% now determine where the good data starts and stops...
if ~isempty(bad)
  start = ([1; bad(1:end)+1]);
  stop = ([bad(1:end); length(good)]);
else
  start=1;
  stop = length(good);
end;

% now only filter over the contiguous chunks of data...
for i=1:length(start)
  ind = good(start(i):stop(i));
   if length(ind)>length(b) & ((ind(end)-ind(1))/length(ind))<3
     d = x(ind);
     % fix edge effects...
     L = length(b);
     d=[(2*d(1)-flipud(d(1:L)));d;2*d(end)-flipud(d((end-L+1):end))];
     dnew = filtfilt(b,a,d);
     y(ind) = dnew((1:length(ind))+L);
   elseif ~isempty(ind)
     y(ind) = NaN*mean(x(ind));
   end; 
end;
if fillgaps
  for i=1:length(start)
    if ~isempty(good)
      ind = good(start(i):stop(i));
      indi = good(start(i)):good(stop(i));
      if length(ind)>1 & length(indi)>1
        y(indi) = interp1(ind,y(ind),indi);
      end;
    end;
  end; 
end;

if doplot
  if length(find(~isnan(y)))>0
    clf
    plot(x);hold on;
    plot(y,'r');
    plot(x,'.');hold on;
    plot(y,'r.');
    title(sprintf('length(b) %d',length(b)));
  end;
end;



  