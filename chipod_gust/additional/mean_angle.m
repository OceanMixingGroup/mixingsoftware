function [A] = mean_angle(x)
%% [A] = mean_angle(x) calculates
%     for a vector x of angles in radians the
%     mean angle between 0 2pi

% convert to complex plain
y = exp(1i*x);

% cal average point in complex plain
A = angle((nanmean(real(y)) + 1i*nanmean(imag(y))));

A(A>2*pi)   = A(A>2*pi)-2*pi;
A(A<0)      = A(A<0)+2*pi;
