%pwp_AddMomentum Adds Momentum to top layer


% Rotate half angle (other half-angle rotation is in main loop in pwp_Run.m)
UV = UV*rotn;         

% Calculate the mixed layer depth
pwp_MixedLayerDepth  

% Add x momentum
UV(1:mld,1) = UV(1:mld,1) + dt*taux(it)*ones(mld,1)/(rho*(z(mld) + dz/2)); 

% Add y momentum
UV(1:mld,2) = UV(1:mld,2) + dt*tauy(it)*ones(mld,1)/(rho*(z(mld) + dz/2)); 

% Apply drag (if nonzero) in x direction 
UV(:,1) = UV(:,1) - dt*r*UV(1:nz,1);  

% Apply drag (if nonzero) in y direction
UV(:,2) = UV(:,2) - dt*r*UV(1:nz,2);  
