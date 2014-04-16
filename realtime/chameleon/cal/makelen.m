function in=makelen(in,size)
% function out=makelen(in,size)
% function changes the length of vector in to be the length size
% size must be a multiple (1/12,.125,.25,.5,1,2,3,4,5,6,7,8,9,10,11,12) of length(in)
oldsize=length(in);
param=oldsize/size;
prm=size/oldsize;
if ~(param-1)
  return  
elseif param>1
  in=in(1:param:oldsize);
  return
elseif prm==2
  in=reshape([in';in'],size,1);
elseif prm==3
  in=reshape([in';in';in'],size,1);
elseif prm==4
  in=reshape([in';in';in';in'],size,1);
elseif prm==5
  in=reshape([in';in';in';in';in'],size,1);
elseif prm==6
  in=reshape([in';in';in';in';in';in'],size,1);
elseif prm==7
  in=reshape([in';in';in';in';in';in';in'],size,1);
elseif prm==8
  in=reshape([in';in';in';in';in';in';in';in'],size,1);
elseif prm==9
  in=reshape([in';in';in';in';in';in';in';in';in'],size,1);
elseif prm==10
  in=reshape([in';in';in';in';in';in';in';in';in';in'],size,1);
elseif prm==11
  in=reshape([in';in';in';in';in';in';in';in';in';in';in'],size,1);
elseif prm==12
  in=reshape([in';in';in';in';in';in';in';in';in';in';in';in'],size,1);
else 
  error('Cannot match the length of each series')
end  
