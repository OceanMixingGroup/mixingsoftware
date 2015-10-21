function Af=DespikeAndFiltADCP(A)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% function Af=DespikeAndFiltADCP(A)
%
% Despike and average ADCP data. 
%
% INPUT:
% A: Velocity structure with fields: dnum (1XNt),z(NzX1),u (Nz X Nt),v(Nz X Nt)
%
% OUTPUT
% Af: Smoothed velocity structure
%------------
% 10/20/15 - AP - apickering@coas.oregonstate.edu
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

%addpath(fullfile(SciencePath,'mfiles','pipestring')) % for despike.m

% edit out very large spikes in velocity
clear ib
ib=find(abs(A.u)>3); A.u(ib)=NaN;
ib=find(abs(A.v)>3); A.v(ib)=NaN;

for iz=1:length(A.z)
    clear ig
    ig=find(~isnan(A.u(iz,:)));
    if length(ig)>1e3;
        A.u(iz,:)=despike(A.u(iz,:),3);
        A.v(iz,:)=despike(A.v(iz,:),3);
    end
end
%~--------    AP 10/19/15 - Try different method of smoothing to reduce
% spikes at edges
clear Af ig

% make empty structure for averaged/filtered data
Af=struct();
Af.dnum=A.dnum(1):1/60/24:A.dnum(end);
Af.u=NaN*ones(length(A.z),length(Af.dnum));Af.v=Af.u;
ig=find(diff(A.dnum)>0); ig=ig(2:end-1)+1;

dt_mins=1 % # minutes to average over
dt=nanmean(diff(A.dnum))*86400;
nc=round(dt_mins*60/dt);
%nc=120;
usm=conv2(A.u,ones(1,nc)/nc,'same');
vsm=conv2(A.v,ones(1,nc)/nc,'same');
for iz=1:length(A.z);
    try
        %Af.u(iz,:)=interp1(A.dnum(ig),nanfilt(b,a,despike(A.u(iz,ig))),Af.dnum);
        %Af.v(iz,:)=interp1(A.dnum(ig),nanfilt(b,a,despike(A.v(iz,ig))),Af.dnum);
        Af.u(iz,:)=interp1(A.dnum(ig),usm(iz,ig),Af.dnum);
        Af.v(iz,:)=interp1(A.dnum(ig),vsm(iz,ig),Af.dnum);
    end
end
%~--------

Af.z=A.z;

% despike again
for iz=1:length(Af.z)
    ig=find(~isnan(Af.u(iz,:)));
    if length(ig)>1e2;
        Af.u(iz,:)=despike(Af.u(iz,:),3);
        Af.v(iz,:)=despike(Af.v(iz,:),3);
    end
end

Af.AvgInfo=['Averaged over ' num2str(dt_mins) 'mins (' num2str(nc) ' points)']

%%