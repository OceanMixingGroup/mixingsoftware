%pwp_BulkRichardson Subroutine to do the bulk Richardson number adjustment
%	Checks to see if BRi is less than critical value, and 
%	if so, deepens mixed layer


vd = sum((diff(UV).^2)')';	     

% Compute bulk Richardson number (without H, i.e., the bulk Richardson number is H*Ri)
Ri = 9.8/rho*(diff(Sig))./vd;	

% Start at base of mixed layer
for i = mld:nz-2			
	% Check if the Bulk Richardson number is less than the critical value
	if (z(i)+dz/2)*Ri(i) < BRiCrit    
		mld = i+1;		% Deepen by one step
		pwp_MixMixedLayer;	% Mix everything up
		
		% Compute the bulk richardson number again  
		Ri = 9.8/rho*(diff(Sig))./(sum((diff(UV).^2)')'); 	
		nbri = nbri+1;		     % Keep track of activity
	else
		% Water column has reached stability. Stop. 
		break          
	end
end          
