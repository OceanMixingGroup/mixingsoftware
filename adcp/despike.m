function [outy]=despike(iny,despikelen,limit,doplot);
% function [outy]=despike(iny,despikelen,limit,doplot);

if nargin<4
  doplot=0;
end;

  outy=iny;
  good = find(~isnan(iny));
  if length(good)>3*despikelen
    b=ones(1,despikelen)./despikelen;a=1;
    lowy = filtfilt(b,a,iny(good));
    dif = abs(lowy-iny(good));
  else
    % this is too short to despike....
%    warning('Time-series too short to despike'); 
    outy=iny;
    return;
  end;
  
 
  if doplot
    hist(dif,100)
  else
    bad = find(dif>limit);
    outy(good(bad))=NaN;
  end;
%keyboard