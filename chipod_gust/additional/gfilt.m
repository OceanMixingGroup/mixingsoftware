function [M] = gfilt(M,varargin)
%% function [M_f] = gfilt( M, Ni, Nj)
%     this function applys a simple moving mean 
%     Ni time for dimension 1 (1 default)
%     Nj time for dimension 2 (1 default)
%
%     use for 2D matries M
%
%     created by
%        Johannes Becherer
%        Mon Aug 15 12:53:47 PDT 2016


if length(varargin)==1
    Ni = varargin{1};
    Nj = varargin{1};
elseif length(varargin)==2
    Ni = varargin{1};
    Nj = varargin{2};
else
    Ni = 1;
    Nj = 1;
end




% nan mask to keep nans in matrix
NANM = ones(size(M));
NANM(isnan(M))=nan;

for i=1:Ni
   M = hfilt(M);
end
for i=1:Nj
   M = vfilt(M);
end

% apply nan mask
M = M.*NANM;

end


function [M] = hfilt(M)
   MM = nan([3,size(M)]);

   MM(1,:,:) = M;    
   MM(2,:,:) = cat(1,M(1,:),M(1:(end-1),:));
   MM(3,:,:) = cat(1,M(2:end,:),M(end,:));

   M = squeeze(nanmean(MM));

end
function [M] = vfilt(M)
   MM = nan([3,size(M)]);

   MM(1,:,:) = M;    
   MM(2,:,:) = cat(2,M(:,2:end),M(:,end));
   MM(3,:,:) = cat(2,M(:,1),M(:,1:(end-1)));

   M = squeeze(nanmean(MM));

end
