function data=get_sw06(ts,tf,mooring_id,varargin);
% Script reads mooring mooring_id data from time ts to time tf
% and returns it in structure DATA
% mooring_id is an integer (37, 38, 39 or 40)
% to read ADV data include parameter 'ADV'
% to read ADP data include parameter 'ADP'
% to read ADCP data include parameter 'ADCP'
% to read beam velocities include parameter 'BEAM'
% to read intencity of the ADP/ADCP signal include parameter 'INT'
% to read PPOD data include parameter 'PPOD'
% to read Microcat CTD data include parameter 'SBD'
%
% To modify beam-to-earth transformation
% to measure short-wavelength internal waves
% use optional argument 'CORRECT_BEAM'
% followed by parameters ALPHA and C (in that order)
% ALPHA is wave propagation angle and 
% C is wave speed
%
% Example: 
% ts=datenum(2006,8,15,0,0,0);
% tf=datenum(2006,8,17,0,0,0);
% mooring_id=37;
% alpha=300;
% c=0.8;
% data=get_sw06(ts,tf,mooring_id,'adp','beam','int',adv','ppod','correct_beam',alpha,c);

datadir='\\mserver\Data\sw06\processed\mooring\';
alpha=[];
c=[];
for i=1:length(varargin)
    if ischar(varargin{i})
        v{i}=lower(varargin{i});
    elseif isempty(alpha)
        alpha=varargin{i};
    else
        c=varargin{i};
    end
end
% v=lower(varargin);

%% load ADP data
if any(strcmp(v,'adp'))
    clear a tfile
    adp_dir='\adp\';
    d=dir([datadir 'sw' num2str(mooring_id) adp_dir 'adp*']);
    for i=1:length(d)
        tfile(i)=datenum(d(i).name(7:21),'yyyymmddTHHMMSS');
    end
    istart=find(tfile<=ts);
    if isempty(istart); istart=1; else istart=istart(end); end
    ifinish=find(tfile>tf);
    if isempty(ifinish); ifinish=length(d); end
    while ifinish(1)==1
        disp('Wrong END time...');
        break
    end
    ifinish=ifinish(1)-1;
    while ifinish<istart
        disp('Wrong START or END time...')
        break
    end
    fields={'time','u','v','w'};
    if any(strcmp(v,'beam'))
        fields=[fields {'vel1','vel2','vel3'}];
    end
    fields2=[];
    if any(strcmp(v,'int'))
        fields2={'int1','int2','int3'};
        fields2a={'amp1','amp2','amp3'};
    end
    for n=1:length(fields)
        a.(char(fields(n)))=[];
    end
    if ~isempty(fields2)
        for n=1:length(fields2)
            a.(char(fields2(n)))=[];
        end
    end
    for i=istart:ifinish
        load([datadir 'sw' num2str(mooring_id) adp_dir d(i).name]);
        if any(strcmp(v,'correct_beam'))
            adp=correct_adp(adp,alpha,c);
        end
        for n=1:length(fields)
            a.(char(fields(n)))=[a.(char(fields(n))) adp.profile.(char(fields(n)))];
        end
        if ~isempty(fields2)
        for n=1:length(fields2)
            a.(char(fields2(n)))=[a.(char(fields2(n))) adp.profile.(char(fields2a(n)))];
        end
        end
    end
    in=find(a.time>=ts & a.time<=tf);
    for n=1:length(fields)
        a.(char(fields(n)))=a.(char(fields(n)))(:,in);
    end
    if ~isempty(fields2)
    for n=1:length(fields2)
        a.(char(fields2(n)))=a.(char(fields2(n)))(:,in);
    end
    end
    head_height=1.2;% height of the ADP head above the bottom
    a.height=head_height-adp.profile.binpos(:,1);
    data.adp=a;
end
%% load RDI ADCP data
if any(strcmp(v,'adcp'))
    clear a
    adcp_dir='\adcp\';
    d=dir([datadir 'sw' num2str(mooring_id) adcp_dir 'adcp*']);
    for i=1:length(d)
        tfile(i)=datenum(d(i).name(8:22),'yyyymmddTHHMMSS');
    end
    istart=find(tfile<=ts);
    istart=find(tfile<=ts);
    if isempty(istart); istart=1; else istart=istart(end); end
    ifinish=find(tfile>tf);
    if isempty(ifinish); ifinish=length(d); end
    while ifinish(1)==1
        disp('Wrong END time...');
        break
    end
    ifinish=ifinish(1)-1;
    while ifinish<istart
        disp('Wrong START or END time...')
        break
    end
    fields={'time','u','v','w'};
    if any(strcmp(v,'beam'))
        fields=[fields {'vel1','vel2','vel3','vel4'}];
    end
    fields2=[];
    if any(strcmp(v,'int'))
        fields2={'int1','int2','int3','int4'};
    end
    for n=1:length(fields)
        a.(char(fields(n)))=[];
    end
    if ~isempty(fields2)
        for n=1:length(fields2)
            a.(char(fields2(n)))=[];
        end
    end
    for i=istart:ifinish
        load([datadir 'sw' num2str(mooring_id) adcp_dir d(i).name]);
        if any(strcmp(v,'correct_beam'))
            adcp=correct_adcp(adcp,alpha,c);
        end
        for n=1:length(fields)
            a.(char(fields(n)))=[a.(char(fields(n))) adcp.(char(fields(n)))];
        end
        if ~isempty(fields2)
        for n=1:length(fields2)
            a.(char(fields2(n)))=[a.(char(fields2(n))) squeeze(adcp.intens(:,n,:))];
        end
        end
    end
    in=find(a.time>=ts & a.time<=tf);
    for n=1:length(fields)
        a.(char(fields(n)))=a.(char(fields(n)))(:,in);
    end
    if ~isempty(fields2)
    for n=1:length(fields2)
        a.(char(fields2(n)))=a.(char(fields2(n)))(:,in);
    end
    end
    head_height=1.2;% height of the ADCP head above the bottom
    a.height=adcp.config.ranges+head_height;
    data.adcp=a;
end
%% load ADV data
if any(strcmp(v,'adv'))
    clear a tfile
    if mooring_id==37 | mooring_id==38
        adv_dir='\adv\';
    else
        adv_dir='\adv1\';
    end
    d=dir([datadir 'sw' num2str(mooring_id) adv_dir 'adv*']);
    for i=1:length(d)
        tfile(i)=datenum(d(i).name(7:21),'yyyymmddTHHMMSS');
    end
    istart=find(tfile<=ts);
    if isempty(istart); istart=1; else istart=istart(end); end
    ifinish=find(tfile>tf);
    if isempty(ifinish); ifinish=length(d); end
    while ifinish(1)==1
        disp('Wrong END time...');
        break
    end
    ifinish=ifinish(1)-1;
    while ifinish<istart
        disp('Wrong START or END time...')
        break
    end
    fields={'time','u','v','w'};
    for n=1:length(fields)
        a.(char(fields(n)))=[];
    end
    for i=istart:ifinish
        load([datadir 'sw' num2str(mooring_id) adv_dir d(i).name]);
        adv.u=adv.vel(1,:);
        adv.v=adv.vel(2,:);
        adv.w=adv.vel(3,:);
        for n=1:length(fields)
            a.(char(fields(n)))=[a.(char(fields(n))) adv.(char(fields(n)))];
        end
    end
    in=find(a.time>=ts & a.time<=tf);
    for n=1:length(fields)
        a.(char(fields(n)))=a.(char(fields(n)))(:,in);
    end
    data.adv1=a;
    % read second adv
    clear a
    if mooring_id==39 | mooring_id==40
        adv_dir='\adv2\';
        d=dir([datadir 'sw' num2str(mooring_id) adv_dir 'adv*']);
        for i=1:length(d)
            tfile(i)=datenum(d(i).name(7:21),'yyyymmddTHHMMSS');
        end
        istart=find(tfile<=ts);
        if isempty(istart); istart=1; else istart=istart(end); end
        ifinish=find(tfile>tf);
        if isempty(ifinish); ifinish=length(d); end
        while ifinish(1)==1
            disp('Wrong END time...');
            break
        end
        ifinish=ifinish(1)-1;
        while ifinish<istart
            disp('Wrong START or END time...')
            break
        end
        fields={'time','u','v','w'};
        for n=1:length(fields)
            a.(char(fields(n)))=[];
        end
        for i=istart:ifinish
            load([datadir 'sw' num2str(mooring_id) adv_dir d(i).name]);
            adv.u=adv.vel(1,:);
            adv.v=adv.vel(2,:);
            adv.w=adv.vel(3,:);
            for n=1:length(fields)
                a.(char(fields(n)))=[a.(char(fields(n))) adv.(char(fields(n)))];
            end
        end
        in=find(a.time>=ts & a.time<=tf);
        for n=1:length(fields)
            a.(char(fields(n)))=a.(char(fields(n)))(:,in);
        end
        data.adv2=a;
    end
end
%% load PPOD data
if any(strcmp(v,'ppod'))
    switch mooring_id
        case 37; ppn='200';
        case 38; ppn='201';
        case 39; ppn='202';
    end
    ppod_dir=['\ppod' ppn '\'];
    load([datadir 'sw' num2str(mooring_id) ppod_dir 'ppod' ppn '_2']); 
    in=find(ppod.time>=ts & ppod.time<=tf);
    ppod.time=ppod.time(in);
    ppod.p=ppod.p(in);
    data.ppod=ppod;
end
%% load Microcats data
if any(strcmp(v,'sbd'))
    load([datadir 'all_lander_microcats']); 
   switch mooring_id
        case 37; is=1;
        case 38; is=2;
        case 39; is=3;
        case 40; is=4;
    end
    in=find(raw(is).ctd.time>=ts & raw(is).ctd.time<=tf);
    sbd.time=raw(is).ctd.time(in);
    sbd.T=raw(is).ctd.T(in);
    sbd.C=raw(is).ctd.C(in);
    sbd.S=raw(is).ctd.S(in);
    data.sbd=sbd;
end
