function [uout]=despike(u,cutt);
if nargin<2
    cutt=2;
end
% [uout]=despike(u);
% 
a=1;
  good = find(~isnan(u));
  if length(good)>length(u)/3
    b = ones(1,min(floor(length(good)/3),40))/min(floor(length(good)/3) ,40);
    baseu = filtfilt(b,a,u(good));
    bad = [find( abs(u(good)-baseu) >cutt*std(u(good)))];
    u(good(bad)) = bad*NaN;
  end
ig=find(~isnan(u));
if length(ig)>length(u)/3
u=interp1(ig,u(ig),1:length(u));
end


uout=u;

