function [ind, tog]=find_bottom(p,az)

% function [ind, tog]=find_bot(p,az) detects the position of the bottom
% based on  the vertical accelerometer.  It returns IND, the slow-sampled
% index of the bottom and tog='y'/'n' depending on whether the bottom was
% indeed found.   
% It looks for the last point having diff(az)<thres2 in the range between 
% 1m above the bottom and the first point where diff(az)>thres1 
% It appears to work for the ch98a data!  
%
% J. Nash, april 1998

if size(p,2)==2
  p=ch(p);
end
if size(az,2)==2
  az=ch(az);
end

% This is the coarse az threshold
thres1=.03;
% This is the fine az threshold, the noise on diff(az) is usually 0.001, so 
% I have set this to be 10 times the noise level.
thres2=.01;

irep=length(az)/length(p);
[p_max,p_ind]=max(p);
first_ind=min(find(p>(p_max-2)));
diff_az=diff(az(first_ind*irep:length(az)));

% this is the line that finds the bottom.  It looks for the last point
% having az<thres2 in the range between 1m above the bottom and the point
% where az exceeds thres1
ind=floor(first_ind+max(find(diff_az(1:min(find(diff_az>thres1)))<thres2))/irep);
tog='y';
if isempty(ind);
  ind=p_ind;
  tog='n';
end