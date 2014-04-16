function adp=trimbad(adp,bad,refname);
% function adp=trimbad(adp,bad,refname);
% trims all the data in adp with the indices given by bad.  This is
% done columnwise.  The idea is that certain data in a time-series
% will be bad and that each column is an entry in the
% time-series.  The optional argument, refname, specifies a
% variable in which has the length of the time-series.
  
% J. Klymak
  
  if nargin<3
    refname='time';
  end;
  
% trims all the bad data
  tt = getfield(adp,refname);
  len = size(tt,2);
  good = setdiff([1:len],bad);
  varnames = fieldnames(adp);
  for i=1:length(varnames)
    var = getfield(adp,varnames{i});
    if size(var,2)==len
      % trim
      var = var(:,good,:);
      adp=setfield(adp,varnames{i},var);
    end;
  end;
return;
  
