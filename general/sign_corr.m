function rr=sign_corr(r,N)
% sign_corr(r,N)
% Significance levels for correlation coefficient 
% with 95% confidence interval (default, but could be changed)
% (on assumption of Gaussian distribution)
% r is the estimated correlation coefficient (i.e. computed by corrcoef)
% N is the number of sample pairs
zalphaovertwo=1.96; % for 95% confidence interval
% zalphaovertwo=2.575; % for 99% confidence interval
zr=0.5*(log(1+r)-log(1-r));
sigz=1/(sqrt(N-3));
zrr(1)=zr-zalphaovertwo*sigz; zrr(2)=zr+zalphaovertwo*sigz;
rr=(exp(2*zrr)-1)./(exp(2*zrr)+1);
