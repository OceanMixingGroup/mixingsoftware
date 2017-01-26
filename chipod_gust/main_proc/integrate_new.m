function [integrate]=integrate_new(kmin,kmax,freqs,spec)
% function integrate(kmin,kmax,freqs,spec) integrates the power
% spectrum between the limits kmin and kmax
% freqs and spec are both column vectors.
% NOTE: may be used to integrate any function spec(freqs)
% 
% The form:
% [...]=integrate(...,'inclusive') may be used to include the frequencies
% that fall at kmin and kmax in the integration.
%
% optimized by Johannes at 23 Jan 2017



  indices=find(freqs>=kmin & freqs<=kmax);

if isempty(indices)
  integrate=NaN;
 return
end
indi=indices(1);
maxnum=length(indices);
indf=indices(maxnum);
% If kmin is less than the minimum frequency we find the first spectrum
% value, otherwise we interpolate its value
if indi==1
  % There are two options- either we linearly interpolate the first value
  % with zero, or we let the new first value equal the old first value.  I'm
  % going to choos the latter for now.
  %  firstspec=spec(1)*kmin/freqs(1);
 firstspec=spec(1);
else
  firstspec=(spec(indi)-spec(indi-1))/(freqs(indi)-freqs(indi-1))*(kmin-freqs(indi-1))+spec(indi-1) ;
end
% If kmax is greater than the maximum frequency we set the last spectrum
% value to zero, otherwise we interpolate its value
if indf==length(freqs);
  lastspec=0;
else
  lastspec=(spec(indf+1)-spec(indf))/(freqs(indf+1)-freqs(indf))*(kmax-freqs(indf))+spec(indf) ;
end
freqs=freqs(:);
spec=spec(:);
newfreqs=[kmin; freqs(indices); kmax];
newspec=[firstspec;spec(indices);lastspec];
% now that we have all of the values, we do the integration
deltas=diff(newfreqs);
integrate=sum(0.5*(deltas.*newspec(1:maxnum+1)+deltas.*newspec(2:maxnum+2)));

