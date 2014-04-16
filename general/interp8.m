function out=interp8(in,num,dim)
% function out=interp8(in,num,dim) interpolates the vector or the 2D matrix 
% in along the dimention dim using a linear
% interpolation to produce an output matrix which is num times as long.
% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:45 $ $Author: aperlin $	
% Originally J. Nash 
[m,n]=size(in);
if nargin<3
  dim=1;
end;
if m==1 | n==1
    if m==1
        out=zeros(m,n*num);
        maxnum=n*num;
        maxn=n;
    elseif n==1
        out=zeros(m*num,n);
        maxnum=m*num;
        maxn=m;
    end
    out(1:num:(maxnum-num+1))=in;
    for i=1:num
        out(1+i:num:(maxnum-2*num+1+i))= ...
            ((num-i)*in(1:(maxn-1))+i*in(2:(maxn)))/num;
        out(maxnum+1-i)=in(maxn);
    end
else
    if dim==1
        out=zeros(m*num,n);
        maxnum=m*num;
        maxn=m;
        out(1:num:(maxnum-num+1),:)=in;
        for i=1:num
            out(1+i:num:(maxnum-2*num+1+i),:)= ...
                ((num-i)*in(1:(maxn-1),:)+i*in(2:(maxn),:))./num;
            out(maxnum+1-i,:)=in(maxn,:);
        end
    elseif dim==2
        out=zeros(m,n*num);
        maxnum=n*num;
        maxn=n;
        out(:,1:num:(maxnum-num+1))=in;
        for i=1:num
            out(:,1+i:num:(maxnum-2*num+1+i))= ...
                ((num-i)*in(:,1:(maxn-1))+i*in(:,2:(maxn)))./num;
            out(:,maxnum+1-i)=in(:,maxn);
        end
    else
        sprintf('Cannot interp a 3D matrix')
    end
end

  
  
