function [displacement]=integrate_spectrum(sp,f,f1,f2)
% function [displacement]=integrate_spectrum(sp,f,f1,f2)
%   integrate spectrum sp over f1 < f < f2
%   return displacement = sqrt(cumtrapz(sp*df));
%   $Revision: 1.1.1.1 $  $Date: 2008/01/31 20:22:42 $
    
df=nanmean(diff(f));
id=find(f>f1&f<f2);
sum=cumtrapz(sp(id)).*df;
displacement=sqrt(sum(end));