% add_to_sum.m
%
% called by process_file_oceanus and initialize_summary_file_oceanus
% to add 1m binned chameleon data to the summary file.

% deternime the top and bottom of the save range and the 
l=length(avg.P);
if length(avg.P)>1
    f=round(avg.P(2))-1;
else
    f=round(avg.P(1));
end
f=nanmax(f,1);
t=l+f-1;
if t>length(cham.depth)
    t=length(cham.depth);
    l=t-f+1;
end

if f>0
    
    % get the index of the position of this file in the summary file
    n=n+1;
    disp(['position in summary file: n = ' num2str(n)])
    
    % average the data into structure cham
    g=9.81;
    cham.depthmax=max(round(max(avg.P)),cham.depthmax);
    cham.EPSILON1(:,n)=NaN; cham.EPSILON1(f:t,n)=avg.EPSILON1(1:l)';
    cham.EPSILON2(:,n)=NaN; cham.EPSILON2(f:t,n)=avg.EPSILON2(1:l)';
%     cham.EPSILON(:,n)=NaN; cham.EPSILON(f:t,n)=avg.EPSILON(1:l)';
    cham.N2(:,n)=NaN; cham.N2(f:t,n)=g*avg.DRHODZ(1:l)'./avg.SIGMA(1:l)';
    cham.SIGMA(:,n)=NaN; cham.SIGMA(f:t,n)=real(avg.SIGMA(1:l)');
    cham.CHI(:,n)=NaN; cham.CHI(f:t,n)= avg.CHI(1:l)';
    cham.THETA(:,n)=NaN; cham.THETA(f:t,n)=real(avg.THETA(1:l)');
    cham.T1(:,n)=NaN; cham.T1(f:t,n)=real(avg.T1(1:l)');
    cham.T2(:,n)=NaN; cham.T2(f:t,n)=real(avg.T2(1:l)');
    cham.SAL(:,n)=NaN; cham.SAL(f:t,n)=real(avg.SAL(1:l)');
    cham.COND(:,n)=NaN; cham.COND(f:t,n)=real(avg.COND(1:l)');
    cham.SCAT(:,n)=NaN; cham.SCAT(f:t,n)=real(avg.SCAT(1:l)');
    cham.AZ2(:,n)=NaN; cham.AZ2(f:t,n)=avg.AZ2(1:l)';
    cham.FALLSPD(:,n)=NaN; cham.FALLSPD(f:t,n)=avg.FALLSPD(1:l)';
    cham.P(:,n)=NaN; cham.P(f:t,n)=avg.P(1:l)';
    cham.pmax(1,n)=max(avg.P);
    cham.DYN_Z(n)=head.dynamic_gz;
    cham.starttime(n,1:20)=head.starttime;
    cham.endtime(n,1:20)=head.endtime;
    cham.direction(n)=head.direction;
    cham.filenums(n)=n;
    cham.castnumber(1,n)=q.script.num;
    cham.filemax=q.script.num;

    % calculate lat and lon
    bad_gps=0;
    if length(head.lon.start)<10; head.lon.start='00000.0000'; bad_gps=1; end
    if length(head.lat.start)<9; head.lat.start='0000.0000'; bad_gps=1; end
    if length(head.lon.end)<10; head.lon.end=head.lon.start; bad_gps=1; end
    if length(head.lat.end)<9; head.lat.end=head.lat.start; bad_gps=1; end

    lat_start_b=str2num(head.lat.start(1:2))+str2num(head.lat.start(3:9))/60;
    lat_end_b=str2num(head.lat.end(1:2))+str2num(head.lat.end(3:9))/60;
    lat_b=lat_start_b;
    lon_start_b=str2num(head.lon.start(1:3))+str2num(head.lon.start(4:10))/60;
    lon_end_b=str2num(head.lon.end(1:3))+str2num(head.lon.end(4:10))/60;
    lon_b=lon_start_b;
    
    cham.lat(1,n)=lat_start_b;
    cham.lon(1,n)=-lon_start_b;
    
    %%%%%%%%
    % calculate the time
    %%%%%%%%
    % weird problem in file 920 onward in YQ14 where the endtime is not
    % written correctly
    % *** usually want to find an average of the start and end times ***
    % *** !!! change this back in the future !!! ***
        
    cham.time(n) = datenum(head.starttime(1:12),'ddmmyyHHMMSS');
    
%     time1 = datenum(head.starttime(1:12),'ddmmyyHHMMSS');
%     time2 = datenum(head.endtime(1:12),'ddmmyyHHMMSS');
%     cham.time(n) = mean([time1,time2]);

    
    % save the summary file
    save([cham.pathname cham.filename],'cham')
end
