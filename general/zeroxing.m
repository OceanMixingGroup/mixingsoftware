function [num,XofZC]=zeroxing(series,x)
%function [num,XofZC]=zeroxing(series,x);
% SERIES iz a function of X
% Finds X-coordinates of SERIES zero crossings 


%first get rid of zeros (to make life simpler - add eps to any zero to make it (very slightly) positive)
ind=find(series==0);
series(ind)=eps;

%now make series start with a postive (if its not, multiply by -1)
if series(1)<0
    series=series.*-1;
end

%now split series up.

indp=find(series>0);
indn=find(series<0);

if series(end)<0
    tog=1;
else
    tog=0;
end


%ok calculate zero crossings:

nulls=0;
dif=diff(indp);
del=find(dif>1);

num=2*length(del);
if tog==1
    num=num+1;
end

if num==0
    return;
end


%setup storage
XofZC(1:num)=NaN;

if del>1
    for n=1:length(del)
        step=nulls+del(n);
        
        %calculate pos to neg zero crossing
  
        left=series([step step+1]);
        right=x([step step+1]);
        XofZC(2.*n-1)=interp1(left,right,0);
    
        %calculate neg to pos zero crossing
        left=series([step+dif(del(n))-1 step+dif(del(n))]);
        right=x([step+dif(del(n))-1 step+dif(del(n))]);
        XofZC(2.*n)=interp1(left,right,0);
        
        nulls=nulls+dif(del(n))-1;
        
    end
end

if tog==1
    n=num;
    step=nulls+length(dif)+1;
    left=series([step step+1]);
    right=x([step step+1]);
    XofZC(n)=interp1(left,right,0);
end

        
    
    
    
    



    
