function [xf]=nanfilt(x,a,b);
% use: [xf]=nanfilt(x,a,b);
% zero-phase filter (filtfilt using a & b) for data including NaNs.
% NaNs are treated such that portions with clean data are filtered
% seperately, and put back to their places retaining NaNs.
%
% Also dummy values of length 1/100th of total lengh, equal to
% record mean are added/removed to the start and end to 
% remove bobbles caused by filtering.

[m,n]=size(x);
x=x(:);
lendum=fix(length(x)./100);
x=cat(1,ones(lendum,1).*nanmean(x(1:lendum)),x,ones(lendum,1).*nanmean(x(end-lendum:end)));


if ~any(isnan(x))
xf=filtfilt(b,a,x);
lenxf=length(xf);
xf([1:lendum,lenxf-lendum+1:lenxf])=[];
xf=reshape(xf,m,n);
else

xf=x;
[in_s,in_e]=get_cleandata_range(x);

	for i=1:length(in_s);
        portion=x(in_s(i):in_e(i));
        if length(portion)>(3*length(b))
        por_filt=filtfilt(b,a,portion);
        xf(in_s(i):in_e(i))=por_filt;
        clear por_filt
        else
        xf(in_s(i):in_e(i))=NaN;  
        end
	end
lenxf=length(xf);
xf([1:lendum,lenxf-lendum+1:lenxf])=[];
xf=reshape(xf,m,n);
end
