function in=lag_sensor(in,lag)
% function out=lag_sensor(in,lag)
% positive lag mean that the sensor responds before the average sensor
% negative lag means that the sensor responds after the average. 

lin=length(in);
 if lag>0
  in(lag+1:lin,:)=in(1:lin-lag,:);
  for j=1:lag
    in(j,:)=in(1,:);
  end
elseif lag<0
  in(1:lin+lag,:)=in(-lag+1:lin,:);
  for j=lag+1:0
    in(lin+j,:)=in(lin,:);
  end
end