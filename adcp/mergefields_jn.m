function dat = mergefields(dat1,dat2,dim2,direction);
% function dat = mergefields(dat1,dat2,dim2);
% merge structures dat1 and dat2 into one structure..
% Optional argument dim2 gives the dimension along which we should
% merge.  If dat1 is empty, then dat2 is returned.
%
% if there is a matrix size mismatch the data is made larger.
 
% $Revision: 1.4 $ $Date: 2003/04/25 20:39:01 $ $Author: aperlin $	

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
  
  if size(data1,3)==1
      %  if this is an NxM array, not an NxMxO 
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
  else
      tmp=[permute(data1,[3  2 1]); permute(data2,[3 2 1])];
      dat = setfield(dat,names{i},permute(tmp,[3 2 1]));  
  end;
end
