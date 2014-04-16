function sdif=sw_sdif(t)

% function sdif=sdif(t) is the fickian diffusivity of salt in seawater.
% From properties of sea water... 'Numerical data and functional
% relationships in Science and Technology'
%  - Oceanography v.3. pg 257 -- from Caldwall 1973 and 1974
%
  
sdif=1e-11*(62.5+3.63*t);

