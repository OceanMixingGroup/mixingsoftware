function avg=select_epsilon(avg,epsilon_glitch_factor)
% select_epsilon(avg) selects the appropriate epsilon for function to select the smallest epsilon from two shear probes if one
% looks glitchy, otherwise use the average.
% Use S1 if only one shear probe is available.
% EPSILON is returned as avg.EPSILON

if nargin<2
  epsilon_glitch_factor=6;
end
min_eps=10^-10;

  tmp=fieldnames(avg);
  	if any(strcmp(tmp,'EPSILON1')) & any(strcmp(tmp,'EPSILON2'))
	  avg.EPSILON=(avg.EPSILON1+avg.EPSILON2)/2;
	  % determine if EPSILON1>>>EPSILON2
	  a=find(avg.EPSILON1>epsilon_glitch_factor*avg.EPSILON2 | isnan(avg.EPSILON1));
	  avg.EPSILON(a)=avg.EPSILON2(a);
	  % determine if EPSILON2>>>EPSILON1
	  a=find(avg.EPSILON2>epsilon_glitch_factor*avg.EPSILON1 | isnan(avg.EPSILON2));
	  avg.EPSILON(a)=avg.EPSILON1(a);
	else
	  % if only one shear probe exists.
	  avg.EPSILON=avg.EPSILON1;
	end
