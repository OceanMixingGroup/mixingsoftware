function [Jb,Jq]=surfaceflux(ta,pr,pa,sst,sss,u10,rh,sw,iflw,lw_cf)
% function [Jb,Jb_ec,Jb_p,Jb_qs,Jb_sw,Jb_lw]=srfbuoyancyflux(ta,pr,pa,sst,sss,u10,rh,sw,iflw,lw_cf)
% a function to compute surface buoyancy flux Jb
% from given air temperature ta [degrees C],
% rate of precipitation pr [kg/m^2/s],
% atmospheric pressure pa [mb],
% sea surface temperature sst [degrees C],
% sea surface salinity sss [PPT],
% wind speed 10 m above the sea surface u10 [m/s],
% relative humidity rh [%],
% net shortwave radiation sw [W/m^2] (negative if downward),
% iflw (1,0) if downward longwave radiation is measured, than
% iflw=1, and lw_cf is the measured downward longwave 
% radiation [W/m^2] (negative).
% if there is no data about downward longwave radiation
% iflw=0, and lw_cf is a cloud fraction (0-1)
%
% OUTPUT
% Jb.t: total buoyancy flux [m^2/s^3] (positive upward)
% Jb.ec: buoyancy flux due to evaporation/condensation
% Jb.p: buoyancy flux due to precipitation
% Jb.qs: buoyancy flux due to sensible heat flux
% Jb.sw: buoyancy flux due to shortwave radiation
% Jb.lw: buoyancy flux due to longwave radiation
% Jq.t: total surface heat flux [W/m^2] (positive upward)
% Jq.ec: heat flux due to evaporation/condensation
% Jq.p: heat flux due to precipitation
% Jq.qs: heat flux due to sensible heat flux
% Jq.sw: heat flux due to shortwave radiation
% Jq.lw: heat flux due to longwave radiation
% 
% formula is based on Dorrestein (1978) (JPO, 9, 1979, p.229-231)
% M=s*beta*(P-E)-alpha/c*(L*E+Q)+alpha*deltaT*P;
% Jb=-g/rho0*M
% $Revision: 1.2 $ $Date: 2009/04/28 00:04:58 $ $Author: aperlin $	
% Originally A. Perlin 

% $$$$$$$$$$ define constants $$$$$$$$$$$$$$$$$$
% salinity in the surface layer [mass ratio]
s=0.035;
% beta=1/rho(drho/ds)_T with rho(s), the density according to the 
% eq. of state with fixed temperature and pressure
beta=0.7;
% specific heat of sea water [J/kg/degK]
c=4000;
% heat of evaporation [J/kg]
L=2.5e6;
% Stefan-Boltzmann constant=5.6696E-8 [W/m^2/K^4]
sigma=5.6696E-8;
% Sea surface emissivity=0.97
emiss=0.97;
% acceleration of gravity [kg/m^3]
g=9.8;
% reference density [kg/m^3]
rho0=1025;
% $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
check=0;
if size(ta,1)>1; check=1; ta=ta'; end
if size(pa,1)>1; pa=pa'; end
if size(rh,1)>1; rh=rh'; end
if size(sst,1)>1; sst=sst'; end
if size(u10,1)>1; u10=u10'; end
if size(sst,1)>1; sst=sst'; end
if size(pr,1)>1; pr=pr'; end
if size(lw_cf,1)>1; lw_cf=lw_cf'; end

% % calculate rate of evaporation minus condensation E [kg/m^2/s]
E = sw_evapor(ta,pa,rh,sst,u10);

%##################################
% calculate sensible heat flux plus net radiation through 
% surface (positive if upward) Q [W/m^2]
if iflw==1
   % if downward longwave radiation is measured
   % than we should calculate upward longwave radiation
    RLU=emiss*sigma*(sst+273.15).^4; 
    RL=RLU+lw_cf;
elseif iflw==0
    % downward longwave radiation is not measured
    % we should calculate net longwave radiation empirically
    es=sw_satprs(ta,1000); %[mb]
    e=rh/100.*es;
    % Brunt's (1932) formula for net longwave radiation 
    % see J.J. Simpson and C.A. Paulson's paper in Quart. J. R. Met. Soc. (1979),
    % 105 pp.487-502 (see also sw_rlngwv.m)
    RL=emiss*sigma*(sst+273.15).^4.0.*(0.39-0.05.*sqrt(e));
    % take into account cloud fraction
    RL=RL.*(1.0-0.8*lw_cf);
end
% sensible heat flux
QS = sw_snhtfl(ta,pa,rh,sst,u10);
% add it all up
Qq=QS+sw+RL;
%######################################

% calculate thermal expansion coeeficient
if size(sss,2)>1; sss=sss'; end
if size(sst,2)>1; sst=sst'; end
alpha=sw_alpha(sss,sst,0);
if size(alpha,1)>1; alpha=alpha'; end 
% calculate temperature of precepitatad water minus temperature of
% surface layer
% (1) temperature of precipitated water
tw=sw_wetbulbtemp(ta,rh);
% summ
if check==0; sst=sst'; end
deltaT=tw-sst;

M=s*beta*(pr-E)-alpha./c.*(L.*E+Qq)+alpha.*deltaT.*pr;
M_ec=-s*beta*E - alpha./c.*L.*E;
M_p=s*beta*pr + alpha.*deltaT.*pr;
M_qs=-alpha./c.*QS;
M_sw=-alpha./c.*sw;
M_lw=-alpha./c.*RL;
% find heat flux Q [W/m^2]
Jq.t=L.*E+Qq-c.*deltaT.*pr; % total heat flux
Jq.ec=L.*E; % heat flux due to evaporation/condensation
Jq.p=-c.*deltaT.*pr; % heat flux due to precipitation
Jq.qs=QS; % sensible heat flux
Jq.sw=sw; % heat flux due to shortwave radiation
Jq.lw=RL; % heat flux due to longwave radiation

Jb.t=-g/rho0*M; % total buoyancy flux
Jb.ec=-g/rho0*M_ec; % buoyancy flux due to evaporation/condensation
Jb.p=-g/rho0*M_p; % buoyancy flux due to precipitation
Jb.qs=-g/rho0*M_qs; % sensible buoyancy flux
Jb.sw=-g/rho0*M_sw; % buoyancy flux due to shortwave radiation
Jb.lw=-g/rho0*M_lw; % buoyancy flux due to longwave radiation
if check==1;
    Jb.t=Jb.t';Jb.ec=Jb.ec';Jb.p=Jb.p';Jb.qs=Jb.qs';Jb.sw=Jb.sw';Jb.lw=Jb.lw';
    Jq.t=Jq.t';Jq.ec=Jq.ec';Jq.p=Jq.p';Jq.qs=Jq.qs';Jq.sw=Jq.sw';Jq.lw=Jq.lw';
end

