%pwp_StaticAdj: Subroutine to do static instability adjustment
%
%	This routine relies on the fact that density increases
%	are always forced from the top (there is no in situ
%	cooling mechanism) so any instability will result in a 
%	downward deepening from the top. The algorithm starts
%	every time with a mixed layer depth of 1 cell and goes
%	downward until static stability is achieved. 
  
Sig = sw_pden(S,T,z,0);           % Compute potential density profile
for i=1:nz-1			% Starting from the surface and working down
    if Sig(i+1) >= Sig(i)       % Check for static instability 
        mld=i;                  % If stable, set mixed layer depth at current depth
        break
    else
	mld=i+1;                % If unstable, set mixed layer depth at next lowest depth
	Sigm = mean(Sig(1:mld));  % Calculate the average density of the mixed layer
	Sig(1:mld) = Sigm*ones(mld,1);  % Set the density of the mixed layer to the mean
	nstin = nstin+1;                % Keep track of the activity
    end
end
if mld > 1 
	pwp_MixMixedLayer; % Now mix all other properties
			   %(temperature, salinity, density, and velocity)
end      
