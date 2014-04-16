function [ind, tog]=find_bot(p,az)
% function [ind, tog]=find_bot(p,az) detects the position of the bottom
% based on  the vertical accelerometer.  It returns IND, the slow-sampled
% index of the bottom and tog='y'/'n' depending on whether the bottom was
% indeed found.   
% It looks for the last point having diff(az)<thres2 in the range between 
% 1m above the bottom and the first point where diff(az)>thres1 
% It appears to work for the ch98a data!  
%
% J. Nash, april 1998
% Remastered by L. Kilcher 2006

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

% I changed this to BE the noise level.  It gets closer to the
% bottom.
%thres2=.001;
%Maybe this isn't a good idea after all: if there aren't any
%abs(diff_az) points below .001 close to the bottom then you miss the
%last little bit of the profile.
% Perhaps 5 times the noise level is better:
%thres2=.005;
% --Levi

irep=length(az)/length(p);
[p_max,p_ind]=max(p);
first_ind=min(find(p>(p_max-2)));
diff_az=diff(az((first_ind*irep):end))*irep;
%diff_az=diff(az((first_ind*irep):(p_ind*irep)))*irep; % This probably
%isn't a good idea either.

% this is the line that finds the bottom.  It looks for the last point
% having az<thres2 in the range between 1m above the bottom and the point
% where az exceeds thres1
ind=floor(first_ind+(find(abs(diff_az(1:find(abs(diff_az)>thres1,1,'first')))<thres2,1,'last')-1)/irep);

tog='y';
if isempty(ind);
  ind=p_ind;
  tog='n';
end
%keyboard
