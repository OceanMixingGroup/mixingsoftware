function dat = cropdata(dat,varargin);
% function dat = cropdata(dat,datmin,datmax);
%  Crops data to be between datmin and datmax.
%
% Can also be called dat = cropdata(dat,[datmin datmax]);
  
% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:45 $ $Author: aperlin $	
% Originally J. Klymak, July 2002
datlim = varargin{1};
if nargin==3
  datlim = [datlim varargin{2}];
end;
bad = find(dat>datlim(2));
dat(bad)=datlim(2);
bad = find(dat<datlim(1));
dat(bad)=datlim(1);

  