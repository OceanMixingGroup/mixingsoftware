function xmid=midpoints(x,ord)
% function xmid=midpoints(x)
  
if nargin<2
  ord=1;
end;

[M,N]=size(x);
if M==1
  transp=1;
  x=x';
else
  transp=0;
end;

if ord==1
  xmid = x(1:end-1,:)+diff(x)/2;
  if transp
    xmid=xmid';
  end;
else
  error('Not implemented');
end;