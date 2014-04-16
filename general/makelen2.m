function out=makelen2(in,prm)
% function out=makelen2(in,prm)
% function changes the length of vector in to be length(in)*prm size
% size must be either integer (ifoutput is longer than input)
% or 1 over integer (if result is a subsample of the original vector)
%   $Revision: 1.2 $  $Date: 2012/04/04 22:53:28 $
% Originally A. Perlin, May 2011
param=1/prm;
if ~(param-1)
    out=in;
  return  
elseif param>1
    if rem(param,floor(param))
        error('length parameter should be either integer or 1 over integer')
        return
    end
    out=in(1:param:end);
    return
end
chk=0;
if size(in,1)==1;
    in=in';
    chk=1;
end
if ~rem(prm,floor(prm))
    sz=length(in)*prm;
    out=NaN*ones(1,length(in)*prm);
    array='in'';';
    array1='in'';';
    for ii=2:prm
        array=[array array1];
    end
    array=array(1:end-1);
    out=eval(['reshape([' array '],sz,1)']);
    if chk
        out=out';
    end
else
    error('length parameter should be either integer or 1 over integer')
    return
end 

