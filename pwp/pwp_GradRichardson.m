% pwp_GradRichardson Subroutine to do gradient Richardson Number adjustment
%	Checks to see if GRi is less than critical value, and 
%	if so, deepens mixed layer

% Set the counter to keep track of how many times the loop runs
jj = 0;            

% Calculate gradient Richardson number (Ri)
Ri = 9.8*dz/rho*abs(diff(Sig))./(sum((diff(UV).^2)')');	       

% Find the indices where Ri is less than the critical value
G = find(Ri(1:end) < GRiCrit);          
% Set an initial parameter for the pwp_Stir function
rmin = 0.2;    
j = 1;
% Continue loop below while Ri > GRiCrit (if [Ri<crit] is not empty...)
while isempty(G)==0
	% if < critical, stir temperature, salinity, velocity
	T = pwp_Stir(rmin,T,G(j));	
	S = pwp_Stir(rmin,S,G(j));	
	UV(:,1) = pwp_Stir(rmin,UV(:,1),G(j));  
	UV(:,2) = pwp_Stir(rmin,UV(:,2),G(j)); 
	% Calculate the stirred density profile
	Sig = sw_pden(S,T,z,0);     
	% Recalculate gradient Richardson number
	Ri = 9.8*dz/rho*abs(diff(Sig)+eps)./(sum((diff(UV).^2)')'); 
	% Find the indices where Ri is less than the critical value
	G = find(Ri(1:end) < GRiCrit);  
	% Find the cell with the lowest Ri (depth index of this cell is is G(j)) 
	j = find(Ri(G)==min(Ri));                                          
	% Set the rmin parameter for the stir function
	rmin = Ri(G(j));
	% Keep track of activity
	ngri = ngri+1;		
	jj = jj+1;
	% Stop the loop after this number of iterations.
	if jj==3000                                             
		% If the warning below is triggered, increase 
		% the number on the RHS of the if-statement
		% (lowering this number can speed up execution, 
		% but the warning indicates critical Ri's remain)
		display(['Maxed out grad Ri at t = ' num2str(it) ...
		'; see pwp_GradRichardson.m, line 37.']);
		Ri_maxout = [Ri_maxout it];
		break
	end
end

% I don't think we need this. It's on the main loop (pwp_Run) already
% Calculate the mixed layer depth
%pwp_MixedLayerDepth;  
