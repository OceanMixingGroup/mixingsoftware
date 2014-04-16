function [pressure  temperature]= convert_ppod6( hdr, pp,  tp )
% use calibration coefficients from header structure
% paroscientific model 2200A
% pp is pressure period in uS
% tp is temperature period in uS
% extract paroscientific coefficients from header
u0 = hdr.parocoefs.U0;
y = hdr.parocoefs.Y;
c = hdr.parocoefs.C;
d = hdr.parocoefs.D;
t = hdr.parocoefs.T;

u= tp -u0 ;  % tp is temperature period

temperature =(y(1).*u) + (y(2).*u.^2) +( y(3).*u.^3 ) ;

cee=c(1)+ (c(2).*u) + (c(3).*u.^2) ;
dee=d(1)+ (d(2).*u);
t0 =t(1)+ (t(2).*u) + (t(3).*u.^2) + (t(4).*u.^3)+ (t(5).*u.^4) ;
aa=1-(t0.^2./double(pp) .^2);
pressure =cee.*aa.*(1-dee.*aa);

end
