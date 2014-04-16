function [b,bint] = neutral_regress(y,x,alpha)
% function [b,bint] = mregress(y,x,alpha)
% mutual regression
% see Emery & Thompson "Data analysis methods in physical oceanography",
% p. 248-249 (in second edition - 2001)
% if regression lines are not forced to go through zero
% eq. (3.13.13) on p. 248 should be used instead
% !!!PLEASE NOTE!!!: eq (3.13.13) has a TYPO. Square root should be
% taken of both numerator and denominator (it's only square root of 
% denominator in the book)
% If regression lines are forced to go through zero, 
% then coefficients of regular regression should be computed first 
% and then equation byx=sqrt(b1/b2) used (p.249)
% [...] = NEUTRAL_REGRESS(Y,X,ALPHA) uses a 100*(1-ALPHA)% confidence level to
% compute BINT (confidence limits)
% default ALPHA=0.05 (95% confidence limits)
% $Revision: 1.1.1.1 $  $Date: 2008/01/31 20:22:45 $
% Originally A. Perlin

if nargin<3
  alpha=0.05;
end;
if size(y,1)==1
    y=y';
end
if size(x,1)==1
    x=x';
end
[pp,ppp] = regress(y,x,alpha);
[pp1,ppp1] = regress(x,y,alpha);
b=sqrt(pp/pp1);
bint(1)=sqrt(ppp(1)/ppp1(2));
bint(2)=sqrt(ppp(2)/ppp1(1));
