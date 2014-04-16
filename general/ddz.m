function d=ddz(z,bc)

%Function D=DDZ(Z,BC); First derivative matrix using centered difference scheme
%Use to calculate the derivative of y, i.e. dy/dz=ddz(z)*y
%Note that y must be a vector, and z must be equally spaced column vector.

%Inputs:
%z --> independent variable
%bc --> specifies boundary conditions
%   [1]-->dirichlet, (y=0 at boundaries)
%   [2]-->one-sided (default)

%Based off of work developed in Bill Smyth's stability class. 
% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:45 $ $Author: aperlin $	
%Originally Emily Shroyer, 2005

if nargin < 2;
    bc=2;
end

del=mean(diff(z));
N=length(z);
d=zeros(N,N);

for n=2:N-1
    d(n,n-1)=-1.;
    d(n,n+1)=1.;
end

if bc==1
    d(1,2)=1;
    d(N,N-1)=-1;
elseif bc==2;
    d(1,1)=-3;
    d(1,2)=4;
    d(1,3)=-1.;
    d(N,N)=3;
    d(N,N-1)=-4;
    d(N,N-2)=1;
end

d=d/(2*del);


