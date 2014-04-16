function [spec,specmin,specmax]=spctm_avg(specs,freqs,newfreqs,alpha)
% function [spec,specmin,specmax]=spctm_avg(specs,freqs,newfreqs,alpha)
% averages the matrices specs and freqs into bins centered on new_freqs.
% Each element of specs corresponds to an element in freqs.  
% alpha gives the (1-alpha) confidence interval (default=0.95)
%   $Revision: 1.1.1.1 $  $Date: 2008/01/31 20:22:42 $
% Originally J.Nash
if nargin==3
  alpha=.95;
end

if mean(size(specs)~=size(freqs))
sprintf('Failed: need to have size(specs) = size(freqs)')
  return 
end
if size(newfreqs,1)==1
  newfreqs=newfreqs';
end
newbounds=sqrt([1e-8 ; newfreqs].*[newfreqs; 1e8]);
len=length(newfreqs);
spec=zeros(len,1);
specmin=zeros(len,1);
specmax=zeros(len,1);
[m,n]=size(freqs);
freqs=reshape(freqs,m*n,1);
specs=reshape(specs,m*n,1);
zg=norminv(1-alpha);
for i=1:len
  indi=find(freqs>newbounds(i) & freqs<=newbounds(i+1));
  if indi
    spec(i)=mean(specs(indi));
    m=length(indi)*2;
    m/2;
    if m<5
      min1=chi2inv(1-alpha,m)/m;
      max1=chi2inv(alpha,m)/m;
    else
      min1=(1-2/9/m+zg*sqrt(2/9/m))^3;
      max1=(1-2/9/m-zg*sqrt(2/9/m))^3;
    end
  specmin(i)=min1*spec(i);
  specmax(i)=max1*spec(i);
  end
end