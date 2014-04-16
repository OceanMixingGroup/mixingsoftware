%pwp_MixedLayerDepth PWP subroutine that finds the mixed layer depth index


% Calculate the difference in density between depths
delta_sig = [diff(Sig)./dz]; 

% Search for a jump in density, using 10^-4 as an arbitrary small number
D = find(abs(delta_sig)>10^-4);

% If there is no jump in density greater than 10^-4, 
% set the mixed layer depth to 1 (the first grid point)
if isempty(D); 
    D = 1; 
end
% Otherwise, choose first value greater than 10^-4 for mixed layer depth
mld = D(1);  % Note mld is an index, not a depth.                    
