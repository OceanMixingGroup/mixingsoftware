% SEAWATER Library
% Version 3.2   19-Apr-2006
%
%                  *******************************
%                  *      SEAWATER Library       *
%                  *                             *
%                  *        Version 3.2          *
%                  *  (for Matlab 5.x onwards)   *
%                  *                             *
%                  *                             *
%                  *     Phillip P. Morgan       *
%                  *           CSIRO             *
%                  *                             *
%                  *       Maintained by         *
%                  *      Lindsay Pender         *
%                  *           CSIRO             *
%                  *                             *
%                  *   Lindsay.Pender@csiro.au   *
%                  *******************************
%
% LIST OF ROUTINES:
%
%     SW_NEW     What's new in this version of seawater.
%
%     SW_ADTG    Adiabatic temperature gradient
%     SW_ALPHA   Thermal expansion coefficient (alpha)
%     SW_AONB    Calculate alpha/beta (a on b)
%     SW_BETA    Saline contraction coefficient (beta)
%     SW_BFRQ    Brunt-Vaisala Frequency Squared (N^2)
%     SW_COPY    Copyright and Licence file
%     SW_CP      Heat Capacity (Cp) of Sea Water
%     SW_DENS    Density of sea water
%     SW_DENS0   Denisty of sea water at atmospheric pressure
%     SW_DIST    Distance between two lat, lon coordinates
%     SW_DPTH    Depth from pressure
%     SW_F       Coriolis factor "f"
%     SW_FP      Freezing Point of sea water
%     SW_G       Gravitational acceleration
%     SW_GPAN    Geopotential anomaly
%     SW_GVEL    Geostrophic velocity
%     SW_INFO    Information on the SEAWATER library.
%     SW_PDEN    Potential Density
%     SW_PRES    Pressure from depth
%     SW_PTMP    Potential temperature
%     SW_SALS    Salinity of sea water
%     SW_SALT    Salinity from cndr, T, P
%     SW_SATAr   Solubility (saturation) of Ar in seawater
%     SW_SATN2   Solubility (saturation) of N2 in seawater
%     SW_SATO2   Solubility (saturation) of O2 in seawater
%     SW_SVAN    Specific volume anomaly
%     SW_SVEL    Sound velocity of sea water
%     SW_SWVEL   Surface wave velocity
%     SW_SMOW    Denisty of standard mean ocean water (pure water)
%     SW_TEMP    Temperature from potential temperature
%     SW_TEST    Run test suite on library
%     SW_VER     Version number of SEAWATER library
%
% LOW LEVEL ROUTINES CALLED BY ABOVE: (also available for you to use)
%
%     SW_C3515   Conductivity at (35,15,0)
%     SW_CNDR    Conductivity ratio   R = C(S,T,P)/C(35,15,0)
%     SW_SALDS   Differiential dS/d(sqrt(Rt)) at constant T.
%     SW_SALRP   Conductivity ratio   Rp(S,T,P) = C(S,T,P)/C(S,T,0)
%     SW_SALRT   Conductivity ratio   rt(T)     = C(35,T,0)/C(35,15,0)
%     SW_SECK    Secant bulk modulus (K) of sea water
%=======================================================================
% OTHER USEFUL ROUTINES ADDED BY J. NASH 9/9/98
%
%     SW_SDIF    Fickian diffusifity of salt as a function of T
%     SW_TCOND   Thermal conductivity at S,T,P
%     SW_TDIF    Thermal diffusivity at S,T,P
%     SW_VISC    Viscosity at S,T,P
%
% FUNCTIONS ADDED BY A.PERLIN 6/12/01
%
%    SW_AIRDEN   Air density at Ta,Pa,Uh (Uh - rel. hum.)
%    SW_ALPHAP   Termal expansion coef. at S,T,P
%    SW_BETAP    Haline contraction coef. at S,T,P
%    SW_CPAIR    Specific heat of moist air at constant pressure at Ta,Pa,Uh
%    SW_DRUG     Wind drug coefficient Cd computed for U10
%    SW_EVAPOR   Evaporation rate at the sea surface at Ta,Pa,Uh,SST,U10
%    SW_RLATFL   Upward latent heat flux at the sea surface at Ta,Pa,Uh,SST,U10
%    SW_RLNGWV   Net longwave radiation at the sea surface at SST,Ta,e,ClFr
%    SW_RMIXRT   Mixing ratio at Ta,Pa,Uh
%    SW_SATHUM   Saturation specific humidity at Ta,Pa
%    SW_SATMIX   Saturation mixing ratio at Ta,Pa
%    SW_SATPRS   Saturation vapour pressure at Ta,Pa
%    SW_SNHTFL   Upward sensible heat flux at the sea surface at Ta,Pa,Uh,SST,U10
%    SW_SPCHUM   Specific humidity at Ta,Pa,Uh
%    SW_U10      Wind speed at 10m height at U,Z
%    SW_VAPPRS   Water vapour pressure at Ta,Pa,Uh
%    SW_VIRTMP   Virtual temperature at Ta,Pa,Uh
%
% FUNCTIONS ADDED BY A.PERLIN 6/12/04
%
%    SW_SATPRS   Saturation vapour pressure in mb at Ta,P
%    SW_WETBULBTEMP Wet bulb temperature at Ta,Rh
%=======================================================================


% Contents.m $Id: Contents.m,v 1.1.1.1 2008/01/31 20:22:51 aperlin Exp $

