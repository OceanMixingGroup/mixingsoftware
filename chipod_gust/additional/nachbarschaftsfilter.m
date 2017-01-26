function [M_f] = nachbarschaftsfilter(M,varargin)
%% die funktion [M_f] = nachbarschaftsfilter(M) mach einen simplen
%nachbarschafts mittelwert für jeden punkt


if length(varargin)==1
    N = varargin{1};
else
    N = 1;
end

% um zu verhindern das die daten in die nan reinwachsen wird ein permanente
% nan maske verwendet
NANM = ones(size(M));
NANM(isnan(M))=nan;

MM = nan([5,size(M)]);
for n=1:N

MM(1,:,:) = M;    
MM(2,:,:) = cat(1,M(1,:),M(1:(end-1),:));
MM(3,:,:) = cat(1,M(2:end,:),M(end,:));
MM(4,:,:) = cat(2,M(:,2:end),M(:,end));
MM(5,:,:) = cat(2,M(:,1),M(:,1:(end-1)));

M = squeeze(nanmean(MM)).*NANM;

% for i=1:size(M,1) 
%     for j=1:size(M,2)
%         if(i>1&&i<size(M,1))
%             ii = [-1:1];
%         elseif(i==1)
%             ii = [0:1];
%         else
%             ii = [-1 0];
%         end
%         if(j>1&&j<size(M,2))
%             jj = [-1:1];
%         elseif(j==1)
%             jj = [0:1];
%         else
%             jj = [-1 0];
%         end
%         M_f(i,j) = nanmean(nanmean(M(ii+i,jj+j)));
%     end
% end
end
M_f=M;