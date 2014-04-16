function d=ddz4(z) 
% Function D=DDZ4(Z); 4th derivative matrix using centered difference
% scheme for independent variable z.

%Use to calculate the 4th derivative of y, i.e. d^4y/dz^4=ddz4(z)*y
%Note that y must be a vector, and z must be equally spaced column vector.

%Based off of work developed in Bill Smyth's stability class. 
% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:45 $ $Author: aperlin $	
%Originally Emily Shroyer, 2005

% check for equal spacing 
if abs(std(diff(z))/mean(diff(z)))>.000001 
disp(['ddz2: values not evenly spaced!']) 
d=NaN; 
return 
end 
del=z(2)-z(1);N=length(z); 
d=zeros(N,N); 
for n=3:N-2 
d(n,n-2)=1.;
d(n,n-1)=-4.; 
d(n,n)=6.; 
d(n,n+1)=-4.;
d(n,n+2)=1.;
end 
d=d/del^4; 
return 
end 

