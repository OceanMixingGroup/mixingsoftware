function [ss] = betap(s,t,p)
%C
%C  CALCULATES THE HALINE CONTRACTION COEFFICIENT
%C   (D(RHO)/DS)/(RHO)
%C
%C  S:      SALINITY     (PSU) 
%C  T:      TEMPERATURE  (C)
%C  P:      PRESSURE     (DBARS)
%C  BETAP:  HALINE CONTRACTION COEFFICIENT  (1/PSU)
%C
%C  USES SIG(S,T,P) AND RHO(S,T,P)
%C
%C   DAVE HEBERT  02/01/86
%C   MODIFIED FOR PC 06/28/88

      ds=1E-2;
      ss=(sw_dens(s+ds,t,p)-sw_dens(s-ds,t,p))./ds./sw_dens(s,t,p)./2.0;
