function [bb]=bootstrap_profile(X,nboot)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function [bb]=bootstrap_profile(X,nboot)
%
% Compute profiles of bootstrap mean and confidence intervals (95%) for a
% set of observations at different depths.
%
% INPUT:
% X : Data to be bootstrapped. Each row is a different depth, each column
% a different observation. Size [M X N]
% nboot : # of times to bootstrap
%
% OUTPUT:
% bb : Vectors of 95% conf. lims and mean:[ lower95% mean upper95%] - Size [M X 3]
%
% Dependencies:
% Uses boot_v5.m to bootstrap at each depth.
%
% 4 Mar. 2015 - A. Pickering - andypicke@gmail.com
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

[M N]=size(X);
bb=nan*ones(M,3);

for whz=1:M    
   clear dataToboot
   dataToboot=X(whz,:);
   dataToboot=dataToboot(~isnan(dataToboot));
   bb(whz,:) = boot_v5(dataToboot,nboot); 
end

return
%%