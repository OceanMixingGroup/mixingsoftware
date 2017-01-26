function [cal] = calc_stratification(T,S,depth)
% calc_stratification is used to calculate stratification from temperature, 
% salinity, and depth. 
%
% Use the syntax:
%
% cal = calc_stratification(T,S,depth);
%
% T = temperature [degree C]
% S = salinity    [psu]
% depth = depth or pressure [dbar or m] 
%       (depth can have dimensions 1x1, Mx1, or MxN for T(MxN) )
% 
% Specifically, the following variables are calculated:
%   cal.rho = sw_dens(S,T,depth)
%   cal.sigma = sw_pden(S,T,depth,0) > reference pressure assumed to be 0m
%       (note: sigma and rho left without subtracting 1000 [kg/m^3])
%
%   cal.Tsort = temperature sorted to decend with depth
%   cal.rhosort = density sorted to ascend with depth
%   cal.sigmasort = potential density sorted to ascend with depth
%       (note, NaNs are preserved when contents sorted
%
%   cal.dTdz = d(T)/dz = depth derivative of sorted temperature [°C/m]
%   cal.drhodz = d(rho)/dz = depth derivative of sorted density [kg/m^4]
%   cal.dsigmadz = d(sigma)/dz = depth derivative of sorted sigma [kg/m^4]
%       (note, depth derivatives are calculated as a simple linear
%       derivative. In the case of TAO data where the data is much more
%       sparce, a cubic akima spline should be used. However, for closely
%       spaced chameleon data, a linear interpolation is better.)
%
%   cal.Nsq = squared buoyancy frequency calculated from density [s^-2]
%       = -g/rho*drho/dz
%   cal.NTsq = squared buoyancy frequency calculated from temperature [s^-2]
%        = g*alpha*dT/dz
%
% Written by S. Warner (January 2016)



%% rotate matrices if necessary

% first determine which dimension is depth and which is time in T and S
[M,N] = size(T);
if M == N
    disp('your depth and time dimensions are equal. make sure your variables')
    disp('are in the form depthXtime')
    badrotation = 0;
elseif M == length(depth)
    % depth is on the first axis. good.
    badrotation = 0;
elseif N == length(depth)
    badrotation = 1;
    T = T';
    S = S';
elseif M ~= length(depth) & N ~= length(depth) & M ~= 1 & N ~= 1
    disp('your depth vector must be the same length as T and S')
    return
end

[DD,TT] = size(T);

%% calculate density and potential density

rho = sw_dens(S,T,depth);
sigma = sw_pden(S,T,depth,0);

%% sort varibles in depth

Tsort = NaN*ones(DD,TT);
rhosort = NaN*ones(DD,TT);
sigmasort = NaN*ones(DD,TT);

for ii = 1:TT
    indgood = ~isnan(T(:,ii));
    Tsort(indgood,ii) = sort(T(indgood,ii),1,'descend');
    clear indgood
    indgood = ~isnan(rho(:,ii));
    rhosort(indgood,ii) = sort(rho(indgood,ii),1,'ascend');  
    clear indgood
    indgood = ~isnan(sigma(:,ii));
    sigmasort(indgood,ii) = sort(sigma(indgood,ii),1,'ascend');  
    clear indgood
end

%% calculate vertical derivatives
% then interpolate back to the correct depth grid

% make a big depth vector
[MM,NN] = size(depth);
if MM == 1 && NN == 1
    disp('no depth vector; cannot take depth derivatives')
    dTdz = NaN*ones(DD,TT);
    drhodz = NaN*ones(DD,TT);
    dsigmadz = NaN*ones(DD,TT);
    Nsq = NaN*ones(DD,TT);
    NTsq = NaN*ones(DD,TT);
    return
elseif MM == DD && NN == 1
    depthbig = repmat(depth,1,TT);
elseif MM == 1 && NN == DD
    depth = depth';
    depthbig = repmat(depth,1,TT);
elseif MM == DD && NN == TT
    depthbig = depth;
end

% do a simple difference of both temperature (and rho and sigma) and depth
% to find dT/dz and then interpolate back to correct depth grid
badz = 0.5*(depthbig(1:end-1,:) + depthbig(2:end,:));

dTdzbadz = (Tsort(1:end-1,:) - Tsort(2:end,:)) ./ (-depthbig(1:end-1,:) - -depthbig(2:end,:));
dTdz = NaN*ones(DD,TT);
for ii = 1:TT
    dTdz(:,ii) = interp1(badz(:,ii),dTdzbadz(:,ii),depthbig(:,ii));
end

drhodzbadz = (rhosort(1:end-1,:) - rhosort(2:end,:)) ./ (-depthbig(1:end-1,:) - -depthbig(2:end,:));
drhodz = NaN*ones(DD,TT);
for ii = 1:TT
    drhodz(:,ii) = interp1(badz(:,ii),drhodzbadz(:,ii),depthbig(:,ii));
end

dsigmadzbadz = (sigmasort(1:end-1,:) - sigmasort(2:end,:)) ./ (-depthbig(1:end-1,:) - -depthbig(2:end,:));
dsigmadz = NaN*ones(DD,TT);
for ii = 1:TT
    dsigmadz(:,ii) = interp1(badz(:,ii),dsigmadzbadz(:,ii),depthbig(:,ii));
end

%% calculate buoyancy frequency

g = 9.81;
rho0 = nanmean(nanmean(sigma));
alpha = sw_alpha(S,T,depth,'temp');

Nsq = -g/rho0 * dsigmadz;

NTsq = g*alpha .* dTdz;


%% rotate back if variables had timeXdepth rather than depthXtime

if badrotation == 1
    
    T = T';
    S = S';
    rho = rho';
    sigma = sigma';
    Tsort = Tsort';
    rhosort = rhosort';
    sigmasort = sigmasort';
    dTdz = dTdz';
    drhodz = drhodz';
    dsigmadz = dsigmadz';
    Nsq = Nsq';
    NTsq = NTsq';
end




%% put all variables in a structure

cal.rho = rho;
cal.sigma = sigma;
cal.Tsort = Tsort;
cal.rhosort = rhosort;
cal.sigmasort = sigmasort;
cal.dTdz = dTdz;
cal.drhodz = drhodz;
cal.dsigmadz = dsigmadz;
cal.Nsq = Nsq;
cal.NTsq = NTsq;











end