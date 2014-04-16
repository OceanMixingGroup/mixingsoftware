%pwp_WriteOutput - every so often, accumulate snapshot of
%	           the situation

sst(nn) = T(1);            % Record the sea surface temperature
zmld = [zmld z(mld)];      % Record the mixed layer depth
v = UV(:,2);               % Record the v velocity
u = UV(:,1);               % Record the u velocity

% Write u,v,T to file 
if writeout==1
    fwrite(fidu,u,'float32');
    fwrite(fidv,v,'float32');
    fwrite(fidt,T,'float32');
    fwrite(fids,S,'float32');
end

% Print snapshots at 
if rem(it,tintv)==0
	% do first time only
	if it/tintv == 1	            		    
		fprintf('Kz = %8.3e, dt = %8.2f hr\n',Kz,dt/3600);
		fprintf(['Percent Tsurf Ssurf MLDepthi StIns '...
		'BRiN  GRiN\n']);
	end
	% average number of times the bulk richardson number 
	% loop runs per time step
	nbri = nbri/tintv;   
	% average number of times the gradient richardson number 
	% loop runs per time step 
	ngri = ngri/tintv;    
	% average number of times the static instability loop 
	% runs per time step
	nstin = nstin/tintv;  
	% time series of the average number of times the bulk 
	% richardson number loop runs
	nnbri = [nnbri nbri]; 
	% time series of the average number of times the 
	% gradient richardson number loop runs
	nngri = [nngri ngri]; 
	% time series of the average number of times the 
	% static instability loop runs
	nnstin = [nnstin nstin];  
	% Print the results on the screen
	fprintf('%6.0f %6.2f %6.2f %6.0f %6.1f %6.1f %6.1f\n',...
	100*(it-tstart)/(tstop-tstart),T(1),S(1),mld*dz,...
	nstin,nbri,ngri)  
	% reset activity counters
	nbri = 0; ngri = 0; nstin = 0; 
end
