function tw=wetbulb(ta,rh)
% a function to calculate wet bulb temperature 
% based on measured air temperature ta [degrees C]
% and relative humidity rh [%]
% Jensen et al. (1990), ASCE Manual No. 70 (see pages 176 & 177) 
% see also http://www.faqs.org/faqs/meteorology/temp-dewpoint/

% calculate saturated vapor pressure es and actual vapor pressure e [kPa]
% es=0.611*exp(17.27*ta./(ta+237.3));
check=0;
if size(ta,1)>1; ta=ta'; check=1; end
if size(rh,1)>1; rh=rh'; end

es=sw_satprs(ta,1000)/10;
e=rh/100.*es;

% compute dewpoint temperature td [degrees C]
td=(116.9+237.3*log(e))./(16.78-log(e));

% compute wet bulb temperature tw [degrees C]
P=100; % [kPa] ambient barometric pressure
gamma=0.00066*P;
delta=4098*e./(td+237.3).^2;
tw=(gamma.*ta+delta.*td)./(gamma+delta);
if check==1; tw=tw';end