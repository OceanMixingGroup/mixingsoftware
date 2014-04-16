function pwp_Run(config,init,forc)
%pwp_Run PWP Model
%   pwp_Run(config,init,forc) Run the Price-Weller-Pinker model 
%	The model needs three input variables. The first, 'config',
%       is a structure containing all the relevant parameters of 
%       the model. Take a look at the pwp_example.mat file. 
%    



% @Tom Farrar, Carlos Moffat, 2006

% Run example dataset if no other given 
if nargin==0 
%if 1==1; % don't use function for development
	load pwp_example
end
% Unpack configuration, clean config
mmv2struct(config); clear config
% Unpack initial conditions, clean init
mmv2struct(init); clear init
% Unpack forcing, clean forc
mmv2struct(forc); clear forc

% check we have a name to assign to the output
if ~exist('runname')
	runname='pwp';
end

% ...because Ri number sometimes involves a 'divide by zero'
warning('off','MATLAB:DivideByZero')      


% Before continuing, check numerical stability criterion on diffusion:
if Kz*dt./(dz)^2>0.5
	error('Err:Err1',['Kz value is numerically unstable! Aborting \n'...
	'Either decrease Kz to ' num2str(.5*(dz)^2/dt) ...
	' or increase dz to ' num2str(sqrt(2*Kz*dt)) '.'])
elseif Km*dt./(dz)^2>0.5
	error('Err:Err2',['Km value is numerically unstable! Aborting. \n'...
	'Either decrease Km to ' num2str(.5*(dz)^2/dt) 
	' or increase dz to ' num2str(sqrt(2*Km*dt)) '.'])
end

% Declare Additional Variables
z  = [dz/2:dz:zmax-dz/2]';  % Vector of depth values
nz = length(z);                  % Number of depth values
nt = length(tstart:tstop);    % Number of timesteps
Ri_maxout = [];                % Counter to record timesteps when grad Ri could not be satisfied
zmld = NaN;                    % initialize an mld for the first timestep

% Differential irradiance curve, i.e. dI/dz in PWP paper
% Surface irradiance history (minus sign for direction
% of difference). 
% Create a staggered depth vector for the differentiation 
zp=[0:dz:zmax];	
dRdz=(-diff(I0(1)*exp(-1/lambda(1)*zp)+...
	    I0(2)*exp(-1/lambda(2)*zp))')./dz;  

%  ... or maybe we should use the analytical form:
%dRdz = I0(1)/lambda(1)*exp(-z./lambda(1))+...
%       I0(2)/lambda(2)*exp(-z/lambda(2)) ;


% Rotation matrix for velocity/momentum
% Rotation effect due to Coriolis
f = sw_f(lat);  

% Half angle of coriolis rotation during dt
% (note "-" is there because inertial rotation is negative in mathematical sense) 
ang    = -f*dt*.5;	        
cosang = cos(ang);
sinang = sin(ang);

% velocity rotation matrix
rotn = [cosang sinang; -sinang cosang];

% Initialize Counters For:
nbri  = 0;  % Bulk Richardson
ngri  = 0;  % Grad. Richardon
nstin = 0;  % Static Instability	   

% Accumulated versions of the above
nnbri = 0;
nngri = 0;
nnstin = 0;  

% Save the initial temperature profile for the plot
T_0 = T;     

% Initialize the timestep counter
nn = 0;

% Almost Ready. Declare Output Files.
if writeout==1        
    %   Open ID's for output files
    fidu = fopen([runname '_u'],'w','b');
    fidv = fopen([runname '_v'],'w','b');
    fidt = fopen([runname '_t'],'w','b');
    fids = fopen([runname '_s'],'w','b');
end

% Ok, Run the Model
fprintf('Main integration started\n')
fprintf('Percent Tsurf Ssurf MLDepth  StIns  BRiN  GRiN\n');

% Step through the times specified by the user
for it=tstart:tstop;            
  % Increment the timestep number
  nn = nn + 1; 	                    
  % Add sensible + latent heat flux (Right Units)
  T(1) = T(1) + (dt/cp/rho/dz).*thf(it);
  % Flux fresh water (latent/precip)
  S(1) = S(1).*(1 - FWFlux(it).*dt/dz);
  % Add short-wave heat to profile
  T = T + (dt/cp/rho).*rhf(it)*dRdz;     
  % Do static instability adjustment
  pwp_StaticAdj;		 
  % Add wind stress induced momentum 
  pwp_AddMomentum;
  % Do bulk Richardson number adjustment
  pwp_BulkRichardson; 
  % Do gradient Richardson number adjustment 
  pwp_GradRichardson;	              
  % Calculate the mixed layer depth   
  pwp_MixedLayerDepth;             
  % Finish rotation of currents 
  % (first half-rotation was in pwp_AddMomentum)
  UV = UV*rotn;
  if nn>1
	  % Advect and diffuse (not really part of PWP, but sometimes useful):
	  %pwp_AdvDif;	              
  end
  pwp_WriteOutput;	              % If time, save data     	
  pwp_PlotOutput;		      % Plot Output
end                                         % End main time step loop

% Finish up
fclose('all');                        % Close the output files
warning('on');                        % restore warnings

% Write .Mat File
fprintf('Almost done, writing .mat file...\n')
pwp_ReadOutput;
fprintf('Done!\n')
