function plot_fcs_profiles( fcs_dn, fcs_up )
%plot FCS CTD profiles
%fcs_dn = CTD descent profiles
%fcs_up = CTD ascent profiles
%above structs are:
%   fcs.dive = array of dive numbers with descent profiles
%   fcs.npts    = array of #datum points per profile
%   fcs.p       = fcs.p(k) = pressure cell array for kth dive
%   fcs.t, fcs.s= ditto for T, S
%   fcs.ti      = ditto if time info (Deep SOLO discrete CTD have time info)
%
% use <left-arrow>, <right-arrow> to scroll through the profiles


dive_dn = fcs_dn.dive; %dive # with profiles on descent
dive_up = fcs_up.dive; %dive # with profiles on ascent
dives   = union(dive_dn, dive_up); %all dives with profiles

%set axis limits so same for all plots
tMin = 9; tMax = 22; sMin = 33.3; sMax = 34.0; zMax = 120;
tAxis = [ tMin, tMax, -zMax, 0 ];
sAxis = [ sMin, sMax, -zMax, 0 ];

nk = length(dives); %total potential #dives
k  = 1;
hFig = figure(101);
while (k<=nk)
    kDive = dives(k); %dive to process
    [ ~, nd, zd, td, sd ] = findDiveFCS( fcs_dn, kDive );
    [ ~, nu, zu, tu, su ] = findDiveFCS( fcs_up, kDive );
    found = ( nd>0 || nu>0  );

    if found %then plot  
        subplot(1,3,1);
        plot(td,-zd,'r-', tu, -zu, 'b-' ); 
        axis(tAxis); grid on;
        xlabel('T [degC]');
        ylabel('Depth [dBar]');
        stit = sprintf('Dive %d',kDive);
        title(stit);
        subplot(1,3,2);
        plot(sd,-zd,'r-', su, -zu, 'b-' ); 
        axis(sAxis); grid on;
        xlabel('S [PSU]');
        title('r=dn, b=up');
        subplot(1,3,3); grid on;
        plot(sd,td,'r-', su, tu, 'b-' ); 
        axis([ sMin sMax tMin tMax ] ); grid on;
        xlabel('S [PSU]');
        ylabel('T [degC]');
       
        set(hFig,'CurrentCharacter', ' '); %set to null,
        pause  %wait for a character
        ch = get(hFig,'CurrentCharacter');
        switch lower(ch)
            case { 'b','r','p', 28  } %left-arrow, go backwards
                k=k-1;
                if (k<1), k=1; end
            case {  'f','n' 29  } %right-arrow, go forwards
                k=k+1;
                if (k>nk), k=nk; end
            case { 'q', 'x' } %quit
                k = nk+1; %force an exit of the while loop
        end
    else
        k = k+1;
    end %then found
end

