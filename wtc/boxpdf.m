function [boxedX,Bx,By]=boxpdf(X)
% Forces the pdf of data to have a boxed distribution using a data adaptive lookup table. 
% 
% [boxedX,Bx,By]=boxpdf(X)
%
% boxedX=N(X) where N is an data adaptive monotonically increasing function.
% boxedX vary between zero and one. 
% 
% Bx,By describes the lookup table
% 
% Aslak Grinsted 2002
[sx i]=sort(X(:));
[n, m] = size(sx);
minx  = min(sx);
maxx  = max(sx);
range = maxx-minx;


% Use the same Y vector if all columns have the same count
eprob = [0.5./n:1./n:(n - 0.5)./n]';

 
%group x's with same value
I=[1; find(diff(sx)~=0)+1]; %unique indices
Bx=sx(I); %unique values
nI=diff([I;length(sx)+1])-1;
By=zeros(length(Bx),1);
for i=length(I):-1:1
    
    By(i,1)=mean(eprob(I(i)+(0:nI(i))));
end
%plot(sx,y);



boxedX=interp1q(Bx,By,X);