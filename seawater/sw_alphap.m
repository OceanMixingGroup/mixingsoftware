function [r] = alphap(s,t,p)
%C
%C  CALCULATES THE THERMAL EXPANSION COEFFICIENT
%C   -(D(RHO)/DT)/(RHO)
%C
%C   S:      SALINITY      (PSU)
%C   T:      TEMPERATURE   (C) 
%C   P:      PRESSURE      (DBARS)
%C   ALPHAP: THERMAL EXPANSION COEFFICIENT  (1/C)
%C
%C  USES SIG(S,T,P) AND RHO(S,T,P)
%C
%C   DAVE HEBERT  02/01/86
%C   MODIFIED FOR PC 06/28/88
%C
dt=1E-2;
r=-(sw_dens(s,t+dt,p)-sw_dens(s,t-dt,p))./dt./sw_dens(s,t,p)./2.00;
