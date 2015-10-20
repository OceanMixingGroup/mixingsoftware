%~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% process_pole_Aug2015_ASIRI_v3.m
%
% Process RDI Sentinel 500kHz adcp data on the side-mount pole for ASIRI cruise.
%
% Same as proces_pole_Aug2015_v2.m, except do each 50MB split file
% separately and then will combine after. Combining them all before
% averaging uses too much memory and crashes matlab...
%
% 09/17/15 - AP
%---------------------------
% Files from Sentinel were very large (2GB) and I was having trouble
% loading them/processing in Matlab. So I split them into ~100mb files with
% BBsplit; this is a modified processing script to read all those smaller
% files and combine into one big structure.
%
% We still need to process some of the deployments separately because the
% ADCP was mounted differently and heading offset is different...
%
% 09/04/15 - A. Pickering - apickering@coas.oregonstate.edu
% 09/05/15 - AP - Computer getting bogged down and crashing when I try to
% do beam to earth transform for entire file. Instead I will do transform
% for each split file and combine.
%~~~~~~~~~~~~~
%
% Original code was designed to check for new files and add them to the
% ones already processed. We are onlly getting a file every few days so I
% am just processing each file by itself. Also NOTE the ADCP alignment was
% different when put back on the pole between the 1st/2nd or 2nd/3rd
% segments, so we will have to compute a different heading offset for each
% of those files...
%
%
% Original by Jen MacKinnon for cruise 1, modifed for Aug 2015 cruise on
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
est_head_offset=0 ; head_offset=255

% root directory for raw ADCP data
dir_data=fullfile(SciencePath,'sidepole','raw')

%~ choose filename to process (these are the large raw files, each of which
% have been split into smaller files)
%
%fnameshort='ASIRI_2Hz_deployment_20150824T043756.pd0';lab='File1';
%fnameshort='ASIRI 2Hz deployment 20150828T043335.pd0';lab='File2';
%fnameshort='ASIRI 2Hz deployment 20150829T123832.pd0';lab='File3';
fnameshort='ASIRI 2Hz deployment 20150904T053350.pd0';lab='File4'
%fnameshort='ASIRI 2Hz deployment 20150908T141555.pd0';lab='File5';
%fnameshort='ASIRI 2Hz deployment 20150911T223729.pd0';lab='File6';
%fnameshort='ASIRI 2Hz deployment 20150915T165213.pd0';lab='File7';
%fnameshort='ASIRI 2Hz deployment 20150917T091838.pd0';lab='File8';

% list of split files (~50mb each)
Flist=dir(fullfile(dir_data,['*' fnameshort(1:end-4) '_split*'])) % some have capital 'S' in split
%%

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
    
    % option to make some plots of raw data
    makeplots=0
    if makeplots==1
        
        % plot beam velocities
        
        close all
        figure(1);clf
        agutwocolumn(1)
        wysiwyg
        
        subplot(411)
        ezpc(A.dnum,A.z,squeeze(A.vel(1,:,:))/1e3)
        caxis(2*[-1 1])
        colorbar
        datetick('x')
        SubplotLetterMW('bm1')
        
        subplot(412)
        ezpc(A.dnum,A.z,squeeze(A.vel(2,:,:))/1e3)
        caxis(2*[-1 1])
        colorbar
        datetick('x')
        SubplotLetterMW('bm2');
        
        subplot(413)
        ezpc(A.dnum,A.z,squeeze(A.vel(3,:,:))/1e3)
        caxis(2*[-1 1])
        colorbar
        datetick('x')
        SubplotLetterMW('bm3');
        
        subplot(414)
        ezpc(A.dnum,A.z,squeeze(A.vel(4,:,:))/1e3)
        caxis(2*[-1 1])
        colorbar
        datetick('x')
        SubplotLetterMW('bm4');
        
        
        %
        % plot beam intensities
        
        close all
        figure(1);clf
        agutwocolumn(1)
        wysiwyg
        
        subplot(411)
        ezpc(A.dnum,A.z,squeeze(A.int(1,:,:)))
        colorbar
        datetick('x')
        SubplotLetterMW('bm1');
        title('beam intensity')
        
        subplot(412)
        ezpc(A.dnum,A.z,squeeze(A.int(2,:,:)))
        colorbar
        datetick('x')
        SubplotLetterMW('bm2');
        
        subplot(413)
        ezpc(A.dnum,A.z,squeeze(A.int(3,:,:)))
        colorbar
        datetick('x')
        SubplotLetterMW('bm3');
        
        subplot(414)
        ezpc(A.dnum,A.z,squeeze(A.int(4,:,:)))
        colorbar
        datetick('x')
        SubplotLetterMW('bm4');
        
        
        % plot beam correlations
        
        close all
        figure(1);clf
        agutwocolumn(1)
        wysiwyg
        
        subplot(411)
        ezpc(A.dnum,A.z,squeeze(A.cor(1,:,:)))
        colorbar
        datetick('x')
        SubplotLetterMW('bm1');
        title('beam correlations')
        
        subplot(412)
        ezpc(A.dnum,A.z,squeeze(A.cor(2,:,:)))
        colorbar
        datetick('x')
        SubplotLetterMW('bm2');
        
        subplot(413)
        ezpc(A.dnum,A.z,squeeze(A.cor(3,:,:)))
        colorbar
        datetick('x')
        SubplotLetterMW('bm3')
        
        subplot(414)
        ezpc(A.dnum,A.z,squeeze(A.cor(4,:,:)))
        colorbar
        datetick('x')
        SubplotLetterMW('bm4');
        
        % *** pgood is all zeros?
        
        % %% plotpgood
        
        close all
        figure(1);clf
        agutwocolumn(1)
        wysiwyg
        
        subplot(411)
        ezpc(A.dnum,A.z,squeeze(A.pgood(1,:,:)))
        colorbar
        datetick('x')
        SubplotLetterMW('bm1');
        title('beam % good')
        
        subplot(412)
        ezpc(A.dnum,A.z,squeeze(A.pgood(2,:,:)))
        colorbar
        datetick('x')
        SubplotLetterMW('bm2');
        
        subplot(413)
        ezpc(A.dnum,A.z,squeeze(A.pgood(3,:,:)))
        colorbar
        datetick('x')
        SubplotLetterMW('bm3');
        
        subplot(414)
        ezpc(A.dnum,A.z,squeeze(A.pgood(4,:,:)))
        colorbar
        datetick('x')
        SubplotLetterMW('bm4');
        
    end % makeplots
    
    %% load ship NAV data
    disp('loading nav data')
    %load('/Volumes/scienceparty_share/data/nav_tot.mat')
    N=loadNavSpecTime([nanmin(A.dnum) nanmax(A.dnum)],SciencePath);
    ttemp_nav=N.dnum_hpr; ig=find(diff(ttemp_nav)>0); ig=ig(1:end-1)+1;
    
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
    
    %    ig=isin(N.dnum_hpr,[nanmin(A.dnum) nanmax(A.dnum)]);
    %
    
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
        % probably approximately right.
        
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
    %    close all
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
    SubplotLetterMW('heading (ship)');
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
    clear A2
    A2.dnum=A.dnum;
    A2.z=A.z;
    A2.u=A.u;
    %A2.v=A.v;
    save(fullfile(SciencePath,'sidepole','mat',[Flist(ifile).name '_proc_raw.mat']),'A2')
    
    
    %% do some basic despiking
    
    addpath(fullfile(SciencePath,'mfiles','pipestring')) % for despike.m
    clear ib
    ib=find(abs(A.u)>5); A.u(ib)=NaN;
    ib=find(abs(A.v)>5); A.v(ib)=NaN;
    
    for iz=1:length(A.z)
        clear ig
        ig=find(~isnan(A.u(iz,:)));
        if length(ig)>1e3;
            A.u(iz,:)=despike(A.u(iz,:),3);
            A.v(iz,:)=despike(A.v(iz,:),3);
        end
    end
    % plot again
    
    %     figure(3);clf
    %     agutwocolumn(1)
    %     wysiwyg
    %     ax = MySubplot(0.15, 0.075, 0.02, 0.06, 0.1, 0.05, 1,4);
    %     cl=0.5*[-1 1]
    %
    %     axes(ax(1))
    %     ezpc(A.dnum,A.z,A.u)
    %     datetick('x')
    %     caxis(cl)
    %     SubplotLetterMW('u')
    %     colorbar
    %     ylabel('depth [m]')
    %
    %     axes(ax(2))
    %     ezpc(A.dnum,A.z,A.v)
    %     datetick('x')
    %     caxis([-1 1])
    %     SubplotLetterMW('v')
    %     colorbar
    %     ylabel('depth [m]')
    
    % smooth a bit in time - here's a 1-minute averaged data file
    
    % 'Af' will be the smoothed/filtered data
    %     clear Af ig
    %     a=1; b=ones(1,60)/60;
    %     Af.dnum=A.dnum(1):1/60/24:A.dnum(end);
    %     Af.u=NaN*ones(length(A.z),length(Af.dnum));Af.v=Af.u;
    %     ig=find(diff(A.dnum)>0); ig=ig(2:end-1)+1;
    %     for iz=1:length(A.z);
    %         try
    %             Af.u(iz,:)=interp1(A.dnum(ig),nanfilt(b,a,despike(A.u(iz,ig))),Af.dnum);
    %             Af.v(iz,:)=interp1(A.dnum(ig),nanfilt(b,a,despike(A.v(iz,ig))),Af.dnum);
    %         end
    %     end
    
    %~--------    AP 10/19/15 - Try different method of smoothing to reduce
    % spikes at edges
    clear Af ig
    Af.dnum=A.dnum(1):1/60/24:A.dnum(end);
    Af.u=NaN*ones(length(A.z),length(Af.dnum));Af.v=Af.u;
    ig=find(diff(A.dnum)>0); ig=ig(2:end-1)+1;
    nc=120;
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
            Af.u(iz,:)=despike(Af.u(iz,:),1);
            Af.v(iz,:)=despike(Af.v(iz,:),1);
        end
    end
    
    %%
    screenheadchanges=0
    if screenheadchanges==1
        % data doesn't do well when ship changes heading quickly
        % blank out a bit of data on either side of quick heading changes
        a=1; b=ones(1,120)/120;
        ttemp=N.dnum_hpr; ig=find(diff(ttemp)>0); ig=ig(1:end-1)+1;
        headf=interp1(N.dnum_hpr(ig),nanfilt(b,a,despike(N.head(ig))),Af.dnum);
        ib=find(abs(diff(headf/mean(diff(Af.dnum))/24/3600))>0.15); % identify "big" heading changes
        ibad=3; % # minutes on either side to blank out of such instances
        for iib=1:length(ib)
            inan=(ib(iib)-ibad):(ib(iib)+ibad);
            Af.u(:,inan)=NaN; Af.v(:,inan)=NaN;
        end
        Af.u=Af.u(:,1:length(Af.dnum));
        Af.v=Af.v(:,1:length(Af.dnum));
        
        % now interpolate back in
        for iz=1:length(Af.z)
            ig=find(~isnan(Af.u(iz,:)));
            Af.u(iz,:)=interp1(Af.dnum(ig),Af.u(iz,ig),Af.dnum);
            Af.v(iz,:)=interp1(Af.dnum(ig),Af.v(iz,ig),Af.dnum);
        end
        
    end % screen heading changes
    %%
    
    clear V dth
    % change name: use V for the sentinel files, and other files use P for pipesting ADCP, S for shipboard adcp.
    V=Af;
    
    % now correct for transducer location, approx 2 m down - this is determined
    % by comparing to shipboard adcp, code for doing this below
    V.z=V.z+2;
    
    %% add lat/lon to ADCP structure
    clear ig
    ig=find(diff(N.dnum_ll)>0); ig=ig(1:end-1)+1;
    V.lon=interp1(N.dnum_ll(ig),N.lon(ig),V.dnum);
    V.lat=interp1(N.dnum_ll(ig),N.lat(ig),V.dnum);
    
    %% plot the final smoothed data
    
    figure(2);clf
    agutwocolumn(1)
    wysiwyg
    ax = MySubplot2(0.15, 0.075, 0.02, 0.06, 0.1, 0.05, 1,3);
    cl=0.5*[-1 1]
    
    % lat/lon
    axes(ax(1))
    [AX,H1,H2]=plotyy(V.dnum,V.lon,V.dnum,V.lat);
    H1.LineWidth=2;
    H2.LineWidth=2;
    AX(1).YLabel.String='Lon';
    AX(2).YLabel.String='Lat';
    grid on
    title([Flist(ifile).name],'interpreter','none')
    datetick('x')
    cb=colorbar;killcolorbar(cb)
    
    % u
    axes(ax(2))
    ezpc(V.dnum,V.z,V.u)
    datetick('x')
    caxis(cl)
    SubplotLetterMW('u_f');
    colorbar
    ylabel('depth [m]')
    
    % v
    axes(ax(3))
    ezpc(V.dnum,V.z,V.v)
    datetick('x')
    caxis(cl)
    SubplotLetterMW('v_f');
    colorbar
    ylabel('depth [m]')
    colormap(bluered)
    xlabel(['Time on ' datestr(floor(nanmin(A.dnum)))])
    
    linkaxes(ax,'x')
    if saveplots==1
        print(fullfile(SciencePath,'sidepole','figures',[Flist(ifile).name '_proc.png']),'-dpng','-r100')
    end
    %
    
    V.source=fname;
    V.head_offset=head_offset;
    V.MakeInfo=['Made ' datestr(now) ' w/ process_pole_Aug2015_ASIRI_v3.m']
    V.Note='Preliminary processing - use with caution! - contact Andy with ?s'
    save(fullfile(SciencePath,'sidepole','mat',[Flist(ifile).name '_proc.mat']),'V')
    
end % which file
%%