function [xd]=deglitch(x,npts,nstd,side)
% function [xd]=deglitch(x,npts,nstd,side)
% x is the series to be deglitched
% npts - number of points to deglitch at a time 
%      - this shold be tuned the data
% nstd - number of std. dev. to remove outliers
% side - outliers will be removed only on positive 
%     (if side='+') or negative (if side='-')
%      side of the mean. If no side is defined, 
%      than outlier will be removed on both sides
% $Revision: 1.4 $  $Date: 2012/07/26 20:46:03 $
% Originally J. Moum

if nargin<3
    nstd=2;
elseif nargin<4
    side='b';
end
np=npts; % no. of points to deglitch at a time
len=length(x);
xd=nan*ones(1,len);
nt=floor(len/np);

for it=1:nt
   xs=x((np*(it-1)+1):np*it);
   idnan=isnan(xs);
   xm=nanmean(xs);
   xsd=nanstd(xs);
   if side=='b'
%        id=find((xs)>(xm+(nstd*xsd)) | (xs)<(xm-(nstd*xsd)));
       id=find(abs(xs-xm)>nstd*xsd);
   elseif side=='+'
       id=find(xs>(xm+(nstd*xsd)));
   elseif side=='-'
       id=find(xs<(xm-(nstd*xsd)));
   else
       disp('Wrong "side" is defined')
       break
   end
   xs(id)=NaN;
   xd((np*(it-1)+1):np*it)=xs;
end

% now do the tail end points
xs=x(np*nt+1:len);
xm=nanmean(xs);
xsd=nanstd(xs);
if side=='b'
    id=find(abs(xs-xm)>nstd*xsd);
elseif side=='+'
    id=find(xs>(xm+(nstd*xsd)));
elseif side=='-'
    id=find(xs>(xm-(nstd*xsd)));
else
    disp('Wrong "side" is defined')
end
xs(id)=NaN;
xd(np*nt+1:len)=xs;
if size(xd,1)~=size(x,1);xd=xd';end

