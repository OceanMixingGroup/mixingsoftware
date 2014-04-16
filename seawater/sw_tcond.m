function tcond=sw_tcond(s,t,p)
% function tcond=sw_tcond(s,t,p) gives the  thermal conductivity
%
%  based on caldwell dsr 21:131-137 (1974)  eqn. 6,7,8
%
%  s  salinity
%  t  temperature (deg. c)
%  p  pressure (dbars)
%
%  tcond  thermal conductivity (j m-1 k-1 s-1)
%
%  tcond(40.,40.,1000.)=0.6623783057965
%
%                                       dave hebert  11/04/86
%
      ak0=0.565403020+t*(1.6999346e-3-t*5.910632e-6);
      f=0.0690-8e-5*t-2.0e-7*p-1.0e-4*s;
      tcond=ak0*(1+f);
 