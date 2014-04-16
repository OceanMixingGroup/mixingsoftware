function dat = decimatefields(dat1,n,dim2);
% function dat = decimatefields(dat1,n,dim2);
% subsample structures dat1 by a factor of n.
% Optional argument dim2 gives the dimension along which we should
% merge. 
%
 
% $Revision: 1.1 $ $Date: 2008/08/12 18:52:09 $ $Author: aperlin $	

if nargin<2
  n=10;
end;

if nargin<3
  dim2=2;
end;

if nargin<4
  direction=2;
end;

dofilt=1;

names = fieldnames(dat1);
dat=[];
for i=1:length(names);
  data1 = getfield(dat1,names{i});
  names{i};
  [M1,N1]=size(data1);
  if M1==1 & N1==1
      % do nothing:
      dat = setfield(dat,names{i},data1);
  elseif M1==1 & dim2==2
      dat = setfield(dat,names{i},data1(1,(n/2):n:end));
  elseif N1==1 & dim2==1
      dat = setfield(dat,names{i},data1((n/2):n:end,1));
  elseif dim2==2 & M1~=1 & N1~=1
      if dofilt
          data1=conv2(data1,ones(1,n)/n,'same');
      end
      dat = setfield(dat,names{i},data1(:,(n/2):n:end));
  elseif dim2==1 & M1~=1 & N1~=1
      if dofilt
          data1=conv2(data1,ones(n,1)/n,'same');
      end
      dat = setfield(dat,names{i},data1((n/2):n:end,:));
  end
end;
