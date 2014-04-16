function adcp = rotateby(adcp,angle);
%

U = adcp.ubt+sqrt(-1)*adcp.vbt;
U = U*exp(sqrt(-1)*angle*pi/180);
adcp.ubt=real(U);
adcp.vbt=imag(U);

U = adcp.u+sqrt(-1)*adcp.v;
U = U*exp(sqrt(-1)*angle*pi/180);
adcp.u=real(U);
adcp.v=imag(U);


