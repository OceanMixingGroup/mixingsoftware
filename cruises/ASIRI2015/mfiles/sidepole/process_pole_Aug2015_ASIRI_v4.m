%~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% process_pole_Aug2015_ASIRI_v4.m
%
% Process RDI Sentinel 500kHz adcp data on the side-mount pole for ASIRI cruise.
%
% Same as proces_pole_Aug2015_v3.m , except we don't do smoothing and
% despiking (instead do for larger combined file after to eliminate edge
% effects).
%
% Based on original codes by Jen MacKinnon for cruise 1, modifed for Aug 2015 cruise on
% R/V Revelle by A. Pickering 08/28/15.
%
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

clear ; close all

% path for scienceparty_share (data)
SciencePath='/Volumes/Midge/ExtraBackup/scienceshare_092015/'

% path for m-files (github repo)
MfilePath='/Users/Andy/Cruises_Research/mixingsoftware/cruises/ASIRI2015/mfiles/'

addpath(fullfile(MfilePath,'nav'))

% option to save plots
saveplots=1

% =1 to estimate heading offset by comparing to ship speed
est_head_offset=0 ; head_offset=255 % found ~=255 for Aug 2015 cruise

% root directory for raw ADCP data
dir_data=fullfile(SciencePath,'sidepole','raw')

%~ choose filename to process (these are the large raw files, each of which
% have been split into smaller files)
whfile=4;
%
switch whfile
    case 1
        fnameshort='ASIRI_2Hz_deployment_20150824T043756.pd0';lab='File1';
    case 2
        fnameshort='ASIRI 2Hz deployment 20150828T043335.pd0';lab='File2';
    case 3
        fnameshort='ASIRI 2Hz deployment 20150829T123832.pd0';lab='File3';
    case 4
        fnameshort='ASIRI 2Hz deployment 20150904T053350.pd0';lab='File4'
    case 5
        fnameshort='ASIRI 2Hz deployment 20150908T141555.pd0';lab='File5';
    case 6
        fnameshort='ASIRI 2Hz deployment 20150911T223729.pd0';lab='File6';
    case 7
        fnameshort='ASIRI 2Hz deployment 20150915T165213.pd0';lab='File7';
    case 8
        fnameshort='ASIRI 2Hz deployment 20150917T091838.pd0';lab='File8';
end

% list of split files (~50mb each)
Flist=dir(fullfile(dir_data,['*' fnameshort(1:end-4) '_split*'])) % some have capital 'S' in split
%

for ifile=1:length(Flist)
    
    close all ;
    clear Atot A fname adcp xadcp nadcp fname_beam_mat fname_earth_mat
    
    % make an empty structure for combined data
    A=struct();
    A.dnum=[];
    A.pitch=[];
    A.roll=[];
    A.heading=[];
    A.u0=[];
    A.v0=[];
    A.heading_adcp=[]
    
    fname=fullfile(dir_data,Flist(ifile).name)
    
    % check if mat file of beam velocity data already exists
    fname_beam_mat=fullfile(SciencePath,'sidepole','mat',[Flist(ifile).name '_beam.mat'])
    fname_earth_mat=fullfile(SciencePath,'sidepole','mat',[Flist(ifile).name '_earth.mat'])
    
    if exist(fname_beam_mat,'file')==2 && exist(fname_earth_mat,'file')==2
        disp('Loading beam velocities')
        load(fname_beam_mat)
        disp('loading earth velocities')
        load(fname_earth_mat)
    else
        disp('no mat exists')
        
    end %  mat files exist
    
    % add data to combined structure
    A.dnum   =[A.dnum    adcp.dnum];
    A.pitch  =[A.pitch   xadcp.pitch];
    A.roll   =[A.roll    xadcp.roll];
    A.heading_adcp=[A.heading_adcp adcp.heading];
    A.heading=[A.heading xadcp.heading];
    
    % u0,v0 are total velocity (ship velocity not removed yet)
    A.u0=[A.u0 nadcp.vel1];
    A.v0=[A.v0 nadcp.vel2];
    
    % ** AP - need to check this for Aug 15  cruise **
    % need to correct for 25 deg beam angle AND 15 deg instrument tilt
    dth=15+25;
    % fix depth - up to now depth is in RANGE! (along beams)
    A.z=adcp.depths*cos(dth*pi/180);
    clear dth
    
    A.u=nan*ones(size(A.u0));
    A.v=A.u;
    
    clear adcp nadcp xadcp%    
    
    %% load ship NAV data
    disp('loading nav data')
    N=loadNavSpecTime([nanmin(A.dnum) nanmax(A.dnum)],SciencePath);
    ttemp_nav=N.dnum_hpr; ig=find(diff(ttemp_nav)>0); ig=ig(1:end-1)+1;
        
    % add lat/lon to ADCP structure
    clear ig
    ig=find(diff(N.dnum_ll)>0); ig=ig(1:end-1)+1;
    A.lon=interp1(N.dnum_ll(ig),N.lon(ig),A.dnum);
    A.lat=interp1(N.dnum_ll(ig),N.lat(ig),A.dnum);

    % calculate ship velocity from it's 5 hz lat/lon, to subtract from measured velocity
    clear dydt dxdt uship vship
    dydt=diff(N.lat)*111.18e3./(diff(N.dnum_ll)*24*3600);
    dxdt=diff(N.lon)*111.18e3./(diff(N.dnum_ll)*24*3600).*cos(N.lat(1:end-1)*pi/180);
    
    uship=interp1(N.dnum_ll(1:end-1)+diff(N.dnum_ll)/2,dxdt,A.dnum);
    vship=interp1(N.dnum_ll(1:end-1)+diff(N.dnum_ll)/2,dydt,A.dnum);
    
    % edit out some bad data
    clear ib
    ib=find(abs(uship)>10 | abs(vship)>10 );uship(ib)=nan;vship(ib)=nan;
    clear ib
        
    %% testing to find heading offset
    % this is the heading offset between the instrument and the ship, i.e. beam
    % 3 was not quite aligned along-ship determined by comparing adcp heading and ship heading, although the adcp
    % heading wanders since it's a compas sitting next to this big metal hull,
    % so this value may need some work,but probalby ok for a first pass...
    % NOTE if beam3 was aligned forward, heading_offset would be 0
    
    %est_head_offset=0;
    if est_head_offset==1
        % this is a simple way of determining approximate heading offset. basically we
        % assume the depth-average adcp speed over the upper 15-30m
        % should be ~= and opposite to the ship's speed. If there are
        % actual strong currents, this won't be true, but on average it is
        % probably approximately right?
        
        clear uv theta dth
        % form complex depth-average adcp velocity
        uv=nanmean(A.u0(1:30,:))+i*nanmean(A.v0(1:30,:));
        theta=[1:360]; clear test1
        % go in a circle and plot the sum of adcp and ship speed
        for ith=1:length(theta)
            %test1(ith)=nanmean(abs(despike(uv0*exp(i*pi*theta(ith)/180)+(uship+i*vship))).^2);
            test1(ith)=nanmean(abs(uv*exp(i*pi*theta(ith)/180)+(uship+i*vship)).^2);
        end
        
        % plot the sum versus angle, and find the minimum; this is our
        % heading offset
        figure(1);clf
        plot(theta,test1)
        [val,I]=nanmin(test1)
        hold on
        plot(theta(I),test1(I),'o')
        dth=theta(I) % this is the minimum offset, our heading correction
        
        clear head_offset uv u0 v0
        head_offset=dth % use value found above
        
    else
        % use head_offset given at beginning
        disp(['using heading offset of ' num2str(head_offset) 'deg'])
    end
    %%
    
    %clear head_offset uv u0 v0
    clear uv u0 v0
    % form complex velocity u + iv
    uv=A.u0+sqrt(-1)*A.v0;
    % rotate by heading offset
    u0=real(uv*exp(i*pi*head_offset/180));
    v0=imag(uv*exp(i*pi*head_offset/180));
    
    %% subtract ship movement (actually add because they have opposite signs)
    A.u=u0+repmat(uship',1,length(A.z))';
    A.v=v0+repmat(vship',1,length(A.z))';
    
    %% plot the data
    %   
    figure(1);clf
    agutwocolumn(1)
    wysiwyg
    ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.02, 1,6);
    
    ig=isin(N.dnum_hpr,[nanmin(A.dnum) nanmax(A.dnum)]);
    
    % heading
    axes(ax(1))
    plot(N.dnum_hpr(ig),N.head(ig))
    grid on
    datetick('x')
    xlim([nanmin(A.dnum) nanmax(A.dnum)])
    cb=colorbar;killcolorbar(cb)
    SubplotLetterMW('head (ship)');
    ylabel('[^o]')
    title([Flist(ifile).name],'interpreter','none')
    xtloff
    
    % ship velocity
    axes(ax(2))
    plot(A.dnum,uship)
    hold on
    plot(A.dnum,vship)
    %ylim(3*[-1 1])
    legend('uship','vship','orientation','horizontal','location','best')
    datetick('x')
    xlim([nanmin(A.dnum) nanmax(A.dnum)])
    cb=colorbar;killcolorbar(cb)
    gridxy
    ylabel('m/s')
    grid on
    xtloff
    
    % total ADPC vel
    axes(ax(3))
    pcolor(A.dnum,A.z,u0)
    axis ij
    shading flat
    colorbar
    caxis(3*[-1 1])
    ylabel('depth [m]')
    datetick('x')
    xlim([nanmin(A.dnum) nanmax(A.dnum)])
    SubplotLetterMW('u0');
    xtloff
    
    % total ADPC vel
    axes(ax(4))
    pcolor(A.dnum,A.z,v0)
    axis ij
    shading flat
    colorbar
    caxis(3*[-1 1])
    ylabel('depth [m]')
    datetick('x')
    xlim([nanmin(A.dnum) nanmax(A.dnum)])
    SubplotLetterMW('v0');
    xtloff
    
    % absolute vel
    axes(ax(5))
    pcolor(A.dnum,A.z,A.u)
    axis ij
    shading flat
    colorbar
    caxis(1*[-1 1])
    ylabel('depth [m]')
    datetick('x')
    xlim([nanmin(A.dnum) nanmax(A.dnum)])
    SubplotLetterMW('u');
    xtloff
    
    % absolute vel
    axes(ax(6))
    pcolor(A.dnum,A.z,A.v)
    axis ij
    shading flat
    colorbar
    caxis(1*[-1 1])
    ylabel('depth [m]')
    datetick('x')
    xlim([nanmin(A.dnum) nanmax(A.dnum)])
    SubplotLetterMW('v');
    colormap(bluered)
    xlabel(['Time on ' datestr(floor(nanmin(A.dnum)))])
    
    linkaxes(ax,'x')
    
    if saveplots==1
        print([SciencePath,'sidepole','figures' Flist(ifile).name '_u0v0uv.png'],'-dpng','-r100')
    end
    
        
    %% 10/20/15 - AP - save data here before filtering/smoothing/despiking
    
    % Previously, I have been processing each split file separately, doing
    % filtering/smoothing etc. because loading all the files together used
    % too much memory. However, this results in some edge effects that i'd
    % like to get rid of. So i'm testing out a new method, saving small
    % files with just u or v, that I will load together after and do
    % smoothing/despiking etc on larger file.
    
    clear V
    V.dnum=A.dnum;
    V.z=A.z;
    V.u=A.u;
    V.v=A.v;
    V.lat=A.lat;
    V.lon=A.lon;
    
    V.head_offset=head_offset;
    V.MakeInfo=['Made ' datestr(now) ' w/ process_pole_Aug2015_ASIRI_v4.m']
    
    save(fullfile(SciencePath,'sidepole','mat',[Flist(ifile).name '_proc_raw.mat']),'V')
       
end % which file
%%