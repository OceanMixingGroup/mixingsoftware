function sonar = RevGetBeamVels(sonar);
% function sonar = RevGetBeamVels(sonar);
% Get beam velocities from covariance and intensity matrices for Revelle
% Sonar. 
%
% Uses the algorithm from Glenn Carter, who presumambly got it from Rob
% Pinkel.
%  
% In addition to calculating the slant velocities, this step calculates
% the speed of sound, the bin positions, time, and adds a few other important
% fields to the sonar structure.  
  
% this does not appear to be in the data structure
  sample_period = 4e-5;
  %  sample_period = 1./sonar.dasinfo.seq_length;
  
% tau is some sort of time scale, used to calc the Vs...
tau = sample_period * sonar.dasinfo.bit_width*sonar.dasinfo.n_bits;

if sonar.dasinfo.mixfreq <= sonar.dasinfo.xmitfreq
  mixer_coeff = 1;
else
  mixer_coeff = -1;
end
 
% need to get the time, pitch

% timemark is in 50 ms increments from start of year.
sonar.time = (sonar.head.timemark)/20/24/3600+...
    datenum(sonar.head.time_mark_year-1,1,1); 

% get depth bins...
c = 1480; %m/s
meters_per_bin = 0.5*(sonar.dasinfo.nsamps*2*sample_period*c);  % ???

nbins = sonar.dasinfo.nbins;
subcode_repeats = sonar.dasinfo.code_reps;
sonar.ranges = c/2 * ((2*[1:nbins]'-1)/2 * ((subcode_repeats-1)/2*tau) - subcode_repeats*tau/2);

% scale the covariances...
Iscale = sonar.int;
cov = sonar.cov(:,1:nbins,:).*Iscale;
quad = sonar.cov(:,(1:nbins)+nbins,:).*Iscale;

% Get the Speed of Sound
T = sonar.head.temperature_stbd;
S= 35;  
csound = 1449.2+4.6*T-.055*T.^2+.00029*T.^3+(1.34-.01*T)*(S-35);
ksound = 2*pi*sonar.dasinfo.xmitfreq./csound;
% calibration coefficient...
calib = mixer_coeff./(2*ksound);
sonar.csound=csound;

for i=1:4
  cal(i,:,:)=repmat(calib,[length(sonar.ranges) 1]);
end;

% this is the beam velocities....
sonar.vel = (1/tau)*cal.*atan2(quad,cov);

