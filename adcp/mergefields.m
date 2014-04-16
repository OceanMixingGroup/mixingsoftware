function dat = mergefields(dat1,dat2,dim2,direction);
% function dat = mergefields(dat1,dat2,dim2);
% merge structures dat1 and dat2 into one structure..
% Optional argument dim2 gives the dimension along which we should
% merge.  If dat1 is empty, then dat2 is returned.
% direction tells how to merge, for example if size(chi.t)=[10 1] ,
% than if we do chi=mergefields(chi,chi,1,2), we get size(chi)=[10 2],
% but if we do chi=mergefields(chi,chi,1,1), we get size(chi)=[20 1]
% default value of dimention is 2.
%
% if there is a matrix size mismatch the data is made larger.
 
% $Revision: 1.1.1.1 $ $Date: 2008/01/31 20:22:41 $ $Author: aperlin $	

if nargin<3
  dim2=[];
end;

if isempty(dat1)
  dat=dat2;
  return;
end;

if nargin<4
  direction=2;
end;


names = fieldnames(dat1);
dat=dat1;
for i=1:length(names);
  data1 = getfield(dat1,names{i});
  data2 = getfield(dat2,names{i});
  [M1,N1]=size(data1);
  [M2,N2]=size(data2);
  if isempty(dim2)
    if direction==2
      if M1>M2
	data2 =[data2;NaN*ones(M1-M2,N2)];
      elseif M2>M1
	data1 =[data1;NaN*ones(M2-M1,N1)];
      end;
      dat = setfield(dat,names{i},[data1 data2]);
    else
      dat = setfield(dat,names{i},[data1; data2]);
    end;
    
  else
    if size(data2,2)==dim2
      if direction==2
	dat = setfield(dat,names{i},[data1 data2]);
      else
	dat = setfield(dat,names{i},[data1; data2]);
      end;
    end;
  end;    
end;
