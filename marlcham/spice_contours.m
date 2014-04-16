% function spc=spice_contours(s,t)
% 	computes spiciness over the ranges
%	specified by s, t 
% 	example - define s=35:1:39;
%	                 t=2:1:15;
%    AP 12/07

function spc=spice_contours(s,t)

spc=[];
%s=34.15:0.001:34.19;
%t=2.2:0.001:2.5;

for i=1:length(s)
   for j=1:length(t)
    spc(i,j)=spice(s(i),t(j));
	end
end
