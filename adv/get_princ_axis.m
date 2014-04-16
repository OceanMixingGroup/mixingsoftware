function [theta,theta_r2] = get_princ_axis(U,V);
% Determine angle theta (in radians) between the principle axis and 
% the direction of the mean current

theta_mean = (180/pi) * atan(nanmean(V')/nanmean(U'));

% Get dir of principle axis
[P,S] = polyfit(U-nanmean(U'),V-nanmean(V'),1);

X = [ones(length(U),1),[U-nanmean(U')]'];
alpha = 0.05;
[B,BINT,R,RINT,STATS] = regress([V-nanmean(V')]',X,alpha);
theta_r2 = STATS(1);

theta_axis = (180/pi) * atan(B(2));

theta = theta_mean - theta_axis; 

Q_plot = 0;
if Q_plot == 1
    figure(2)
    clf
    plot(U,V,'.')
    P_fit = polyval(P,U-nanmean(U'));
    hold on
    plot(U,P_fit+nanmean(V'),'r')
    XL = get(gca,'xlim');
    YL = get(gca,'ylim');
    slope = nanmean(V')/nanmean(U');
    plot(XL,slope*XL,'k')
    plot(0,0,'k+',0,0,'ko')
    DEL = 0.2;
    axis([nanmean(U')-DEL nanmean(U')+DEL nanmean(V')-DEL nanmean(V')+DEL])
    % axis square
    title(['theta: ' num2str(theta) '; degrees'])
    % pause
end

% Convert to radians
if theta>90
    theta=theta-180;
elseif theta<-90
    theta=180-theta;
end
theta = (pi/180) * theta;

