function adcp=make_workhorse_mat(fname,isbeamtoearth,mag_incl,align_cor);
% adcp=make_workhorse_mat(fname,beam,isbeamtoearth,mag_incl);
% makefile to read raw workhorse data and save matlab structure
% fname - file name
% isbeamtoearth (0,1) - translate from beam to earth coordinats if 1
% mag_incl - if not zero, rotates velocity to account for
%           magnetic inclination [degrees] (if needed)
% align_cor - ADCP misalignment correction [degrees]

if nargin < 4
    align_cor=0;
    if nargin < 3 
        mag_incl=0;
        if nargin <2
            isbeamtoearth=0;
        end
    end
end
adcp=workhorsetosci(fname);
% convert from beam to earth coordinates if needed
if adcp.cfg.coordtransform(1)==0
    earth='velocities are in beam coordinates';
else
    earth='velocities are in earth coordinates'
end
if isbeamtoearth==1
    fadcp=beam2earth_workhorse(adcp);
    adcp.vel1=fadcp.vel1;
    adcp.vel2=fadcp.vel2;
    adcp.vel3=fadcp.vel3;
    adcp.vel4=fadcp.vel4;
    earth='velocities have been rotated into Earth coordinates';
end
% correct for magnetic inclination
if mag_incl & allign_angle ~= 0
    UU=fadcp.vel1+sqrt(-1).*fadcp.vel2;
    UU=UU.*exp(sqrt(-1)*(mag_incl+align_cor)*pi/180);
    adcp.vel1=real(UU);
    adcp.vel2=imag(UU);
end
incl=['magnetin inclination ' num2str(mag_incl) ' deg has been applied'];
algn=['misalignment correction ' num2str(align_cor) ' deg has been applied'];

adcp.readme={earth;incl;algn;'made with make_workhorse_mat.m'};
