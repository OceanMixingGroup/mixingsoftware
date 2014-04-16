function newadcp = processadcp(adcp);

% despike
  newadcp=adcp;  
  newadcp.vel2=despike(adcp.vel2',20,0.15,0)';
  newadcp.vel1=despike(adcp.vel1',20,0.15,0)'; 
  newadcp.vel3=despike(adcp.vel3',20,0.05,0)';
  newadcp.vel4 = adcp.vel4;
  
  bad = find(abs(adcp.vel4(:))>0.2);
  newadcp.vel1(bad)=NaN;
  newadcp.vel2(bad)=NaN;
  newadcp.vel3(bad)=NaN;
  newadcp.vel4(bad)=NaN;

  
  if isfield(adcp,'echo1')
    newadcp.echo = adcp.echo1+adcp.echo2+adcp.echo3+adcp.echo4;
  else
    newadcp.echo = NaN*adcp.time2;
  end;
  
  newadcp.echo=newadcp.echo/4;
  newadcp.time = adcp.time2;
  newadcp.time1=[];
  newadcp.echo1=[];
  newadcp.echo2=[];
  newadcp.echo3=[];
  newadcp.echo4=[];
  newadcp.percentgood1=[];
  newadcp.percentgood2=[];
  newadcp.percentgood3=[];
  newadcp.percentgood4=[];
  newadcp.binpos = newadcp.binpos(end-29:end)';
  
  % take the shears.
  
  b = ones(20,1)/20;a=1;
  newadcp.shearu = gappy_filter(b,a,...
                                diff(newadcp.vel1)'/median(diff(newadcp.binpos)),20,1)';
  b = ones(2,1)/2;a=1;
  newadcp.shearu = gappy_filter(b,a,newadcp.shearu,3,1);
  newadcp.shearz = newadcp.binpos(1:end-1)+median(diff(newadcp.binpos));
  
  b = ones(20,1)/20;a=1;
  newadcp.shearv = gappy_filter(b,a,...
                                diff(newadcp.vel2)'/median(diff(newadcp.binpos)),20,1)';
  b = ones(3,1)/3;a=1;
  newadcp.shearv = gappy_filter(b,a,newadcp.shearv,3,1);
  
  
  