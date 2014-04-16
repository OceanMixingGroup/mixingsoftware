%pwp_AdvDif.m: Subroutine to advect and diffuse.  


% Advection: PRELIMINARY!! This is not guaranteed to be correct, but it does 
% seem stable for reasonable values of w.
% Runge-Kutta 2nd order (i.e. Huen's method, p.465 of Mathews and Fink)
% BC's applied are that Tz=0 at top and bottom boundaries

Sold=S; Told=T; UVold=UV; 		              % save old values first

% Temperature advection
[foo,Tz]=deriv1(Told,dz,z,2);
Tz=[0; Tz; 0];
Tfd=Told+dt.*(-w(nn-1,:)'.*Tz);
[foo,Tz2]=deriv1(Tfd,dz,z,2);
Tz2=[0; Tz2; 0];
f1=-w(nn-1,:)'.*Tz;
f2=-w(nn,:)'.*Tz2;
T=Told+dt./2.*(f1+f2);
% Salinity advection
[foo,Sz]=deriv1(Sold,dz,z,2);
Sz=[0; Sz; 0];
Sfd=Sold+dt.*(-w(nn-1,:)'.*Sz);
[foo,Sz2]=deriv1(Sfd,dz,z,2);
Sz2=[0; Sz2; 0];
f1=-w(nn-1,:)'.*Sz;
f2=-w(nn,:)'.*Sz2;
S=Sold+dt./2.*(f1+f2);
% Momentum advection (UV):
[foo,UVz]=deriv1(UVold,dz,z,2);
UVz=[[0 0]; UVz; [0 0]];
UVfd=UVold+dt.*([-w(nn-1,:)' -w(nn-1,:)'].*UVz);
[foo,UVz2]=deriv1(UVfd,dz,z,2);
UVz2=[[0 0]; UVz2; [0 0]];
f1=[-w(nn-1,:)' -w(nn-1,:)'].*UVz;
f2=[-w(nn,:)' -w(nn,:)'].*UVz2;
UV=UVold+dt./2.*(f1+f2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Diffusion:
% Temperature diffusion
T_zz=-[0; -T(1:nz-2)+2.*T(2:nz-1)-T(3:nz); 0]./(dz.^2);
T=T+dt.*Kz.*T_zz;
% Salinity diffusion
S_zz=-[0; -S(1:nz-2)+2.*S(2:nz-1)-S(3:nz); 0]./(dz.^2);
S=S+dt.*Kz.*S_zz;
% Momentum diffusion
U_zz=-[0; -UV(1:nz-2,1)+2.*UV(2:nz-1,1)-UV(3:nz,1); 0]./(dz.^2);
UV(:,1)=UV(:,1)+dt.*Km.*U_zz;
V_zz=-[0; -UV(1:nz-2,2)+2.*UV(2:nz-1,2)-UV(3:nz,2); 0]./(dz.^2);
UV(:,2)=UV(:,2)+dt.*Km.*V_zz;
