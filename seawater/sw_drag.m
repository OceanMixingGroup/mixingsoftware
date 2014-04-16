function [out] = sw_drag(uz)
%C
%C  DRAG=sw_drag(uz)
%C  This function calculates the aerodynamic drag coefficient over the
%C  sea surface. The formulae are based on W.G.Large and S.Pond JPO Vol. 11,
%C  No. 3, (March 1981) pp.324-336
%C
%C  DRAG ---------- The drag coefficient
%C  UZ  ----------- The wind speed at 10 m height above the sea surface (m/s)
%C
%C  uz is the wind speed at 10m above the sea surface
out=0.0012*ones(size(uz));
out(uz>=11)=0.00049+0.000065*uz(uz>=11);
% for iii=1:length(uz);
% 	if (uz(iii) < 11.0)
%   		i(iii)=0.0012;
% 	else
%   		i(iii)=0.00049+0.000065*uz(iii);
% 	end;
% end;

