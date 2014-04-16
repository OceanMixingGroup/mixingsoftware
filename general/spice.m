%function spice(s,t)
%A P. Flament
%T A state variable for characterizing water masses and their diffusive 
% stability: spiciness
%J Progr. Oceanog.
%D 2001
%O (in press, SOEST contr. 5323)
%expression of spiciness
% Check values
% p t s = 0 0 35  -> spice = 0 by design
% p t s = 0 20 35	-> spice = 3.32118
% p t s = 0 10 35	-> spice = 1.13119


function sp=spice(s,t)	%/* pressure can only be 0 in this version  */

b=zeros(6,5)*NaN;

b(1,1) = 0;
b(1,2) = 7.7442e-001;
b(1,3) = -5.85e-003;
b(1,4) = -9.84e-004;
b(1,5) = -2.06e-004;

b(2,1) = 5.1655e-002;
b(2,2) = 2.034e-003;
b(2,3) = -2.742e-004;
b(2,4) = -8.5e-006;
b(2,5) = 1.36e-005;

b(3,1) = 6.64783e-003;
b(3,2) = -2.4681e-004;
b(3,3) = -1.428e-005;
b(3,4) = 3.337e-005;
b(3,5) = 7.894e-006;

b(4,1) = -5.4023e-005;
b(4,2) = 7.326e-006;
b(4,3) = 7.0036e-006;
b(4,4) = -3.0412e-006;
b(4,5) = -1.0853e-006;

b(5,1) = 3.949e-007;
b(5,2) = -3.029e-008;
b(5,3) = -3.8209e-007;
b(5,4) = 1.0012e-007;
b(5,5) = 4.7133e-008;

b(6,1) = -6.36e-010;
b(6,2) = -1.309e-009;
b(6,3) = 6.048e-009;
b(6,4) = -1.1409e-009;
b(6,5) = -6.676e-010;

s=(s-35.);
sp=0.;

T=1.;
for i=1:6

	S=1.;
	for j=1:5

		sp=sp+b(i,j)*T.*S;
		S=S.*s;
	end
	T=T.*t;
end

