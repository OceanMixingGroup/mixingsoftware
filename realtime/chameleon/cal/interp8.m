function out=interp8(in,num)
% function out=interp8(in,num) interpolates the vector in using a linear
% interpolation to produce an output vector which is num times as long.
% jnas
[m,n]=size(in);
if m==1
  out=zeros(m,n*num);
  maxnum=n*num;
  maxn=n;
elseif n==1
  out=zeros(m*num,n);
  maxnum=m*num;
  maxn=m;
else 
  sprintf('Need a vector input, not a matrix');
  return 
end
out(1:num:(maxnum-num+1))=in;
for i=1:num
  out(1+i:num:(maxnum-2*num+1+i))= ...
      ((num-i)*in(1:(maxn-1))+i*in(2:(maxn)))/num;
  out(maxnum+1-i)=in(maxn);
end

  
  
