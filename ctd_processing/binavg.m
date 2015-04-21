function[ybin,num]=binavg(x,y,xbin,cutt)

% cutoff for entries within a bin
if ~exist('cutt'); cutt=3; end

[m,n]=size(x);
x1=reshape(x,1,m*n);
y1=reshape(y,1,m*n);
ybin=NaN*xbin; num=NaN*xbin;
nn=length(xbin);

ig=find(~isnan(x1)&~isnan(y1));
x1=x1(ig); y1=y1(ig);
 
dbin=diff(xbin);

%1st bin
ii=find((x1>(xbin(1)-dbin(1)/2))&(x1<(xbin(1)+dbin(1)/2)));
if length(ii)>cutt
   ybin(1)=mean(y1(ii)); num(1)=length(ii);
end

%last bin
ii=find((x1>(xbin(nn)-dbin(nn-1)/2))&(x1<(xbin(nn)+dbin(nn-2)/2)));
if length(ii)>cutt
ybin(nn)=mean(y1(ii)); num(nn)=length(ii);
end

%other bins
for i=2:(nn-1)
   ii=find((x1>(xbin(i)-dbin(i-1)/2))&(x1<(xbin(i)+dbin(i)/2)));
   if length(ii)>cutt
      ybin(i)=mean(y1(ii)); num(i)=length(ii);
   end
end


