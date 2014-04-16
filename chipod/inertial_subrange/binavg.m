function [bin] = binavg(frq,spc,binwidth)
% function [bin] = binavg(frq,spc,binwidth)
%       function to bin average spectral coefficients
%       frq - frequencies
%       spc - spectral coefficient
%       binwidth - user-selected averaging width (log10)
%

len=length(frq);

nbins=(log10(max(frq))-log10(min(frq)))/binwidth-1;

bin.dof=[];
bin.frq=[];
bin.spc=[];

for ibin=1:nbins
   lgmnfrq=log10(min(frq))+ibin*binwidth;
   lgmxfrq=log10(min(frq))+(ibin+1)*binwidth;
   id=find(log10(frq) >= lgmnfrq & log10(frq) <= lgmxfrq);

   if length(id)>0
       bin.dof=[bin.dof length(id)];
       bin.frq=[bin.frq nanmean(frq(id))];
       bin.spc=[bin.spc nanmean(spc(id))];
   else
       bin.dof=[bin.dof nan];
       bin.frq=[bin.frq nan];
       bin.spc=[bin.spc nan];
   end

end
