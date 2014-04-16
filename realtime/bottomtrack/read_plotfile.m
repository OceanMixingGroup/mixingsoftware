  fin =fopen(fname_plotinfo,'r');
  if fin<0
    warning(['Can''t open ' fname_plotinfo]);
    return;
  end;
  
  [infomat,nscans]=fscanf(fin,'%f',4);
  if nscans==4
    
    set(plotinfo.zup,'string',num2str(infomat(1)));
    set(plotinfo.zdown,'string',num2str(infomat(2)));
    set(plotinfo.lleft,'string',num2str(infomat(3)));
    set(plotinfo.lright,'string',num2str(infomat(4)));
    % info.surveyname = plotinfo.surveyname;
  else
    warning(['Cannot open ' fname_plotinfo]); 
  end;
  