function [I] = find_series1s(x, N)
%% [I] = find_series1s(x, N)
%
%     This function identifies all sub vectors of x that contain a series of
%     ones that is at least N elements long.  This can be used to find parts of
%     a vector that fullfill a certain condition and are at least N elements
%     long
%
%     INPUT
%        x : vector of booleans
%        N : threshold for consecutive ones
%
%     OUTPUT
%        I{} : cell array with indexes of sub vectors of x 
%
%     
%   created by: 
%        Johannes Becherer
%        Mon Oct 31 12:21:51 PDT 2016


% test 
%N =0 ;
%x = [0 1 0 1 1 1 0 0 0 1 1 0];

% initialize return value
I = [];

% set all not ones to zero
x(x~=1) = 0;

% get differences
dx = diff(x);

% find changes (jumps)
di = find(dx~=0);

% find sub vectors that are larger than the Threshold value N
dii = find(diff(di)>=N);

% loop through all large sub vectors
cnt = 1;
for j = 1:length(dii)
   % get corresponding indexes of orginal vector
   ii = (di(dii(j))+1):di((dii(j)+1));

   % find out if 0 or 1 vector 
   if(x(ii(1)) == 1)
      I{cnt} = ii;
      cnt = cnt +1;
   end

end
