function y = filtfiltnan(b,a,x)

% filtfilt, but removes nans
y=NaN*x;
ig=find(~isnan(x));

x=interp1(ig,x(ig),1:length(x));
ig=find(~isnan(x));
y(ig)=filtfilt(b,a,x(ig));
