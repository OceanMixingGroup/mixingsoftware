function I_fact = calc_I(U_mean,U_std,theta);
% function I_fact = calc_I(U_mean,U_std,theta);

x_step = 0.01;
x = -5:x_step:5;
A = (U_std/U_mean)^(2/3) /sqrt(2*pi);
B = 2*(U_mean/U_std)*cos(theta);
C = (U_mean/U_std)^2;

P = A * ((x.^2 - B*x + C).^(1/3)) .* exp(-(x.^2)/2); 
I_fact = x_step * sum(P);


Q_plot = 0;
if Q_plot==1
    figure(1)
    clf
    plot(x,P,'b')
    hold on
    plot(x,x_step*cumsum(P),'r')
    xlabel('x')
    legend('P','cumsum(P) / x_step',2)
    title(['I\_fact = ' num2str(I_fact) '   P = [x^2 -Bx + C]^{1/3} * e^{-x^2/2}'])
end





