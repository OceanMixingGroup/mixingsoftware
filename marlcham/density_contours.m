% function dens=density_contours(s,t)
% 	computes density over the ranges
%	specified by s, t 
%	I wrote this to use to plot density
%	contours on s T-S plot, hence the name
% 	example - define s=35:1:39;
%	                 t=2:1:15;
%    jnm 9/99

function dens=density_contours(s,t)

dens=[];
%s=34.15:0.001:34.19;
%t=2.2:0.001:2.5;

for i=1:length(s)
   for j=1:length(t)
    dens(i,j)=sw_dens(s(i),t(j),0);
	end
end
