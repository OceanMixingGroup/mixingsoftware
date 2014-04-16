% process_file.m
try
    load_file=[q.script.pathname q.script.prefix sprintf('%04.3f',nextfile/1000)]
    next_file=[q.script.pathname q.script.prefix sprintf('%04.3f',(nextfile+1)/1000)];
    if exist(next_file,'file')
        disp(['processing file ' load_file])
        q.script.num=nextfile;
        nextfile=nextfile+1;
        save nextfile nextfile
        temp=num2str(q.script.num+10000);
        fn=[path_cham 'mat\' q.script.prefix temp(2:5)];
        while exist([fn '.mat'],'file')
            disp(['processing file ' load_file])
            q.script.num=nextfile;
            nextfile=nextfile+1;
            save nextfile nextfile
            temp=num2str(q.script.num+10000);
            fn=[path_cham 'mat\' q.script.prefix temp(2:5)];
            load([fn '.mat'])
            add_to_sum
        end
        clear global head data cal
        global data cal head
        %
        % load raw data
        %
        [data head]=raw_load(q);
        %
        % calibrate raw data
        %
        cali_realtime
        
        nfft=256;
        
        % define series to be processed
        %
        % q.series={'fallspd','t','c','s','theta','sigma','epsilon1','epsilon2','chi','az2','dtdz','drhodz','scat','ax_tilt','ay_tilt','wd2'};
        q.series={'fallspd','t','c','s','theta','sigma','epsilon1','epsilon2','chi','n2','az2','dtdz','drhodz','scat','ax_tilt','ay_tilt'};
        warning off
        
        if bad~=1
            %
            % average calibrated data into 1m bins
            %
            avg=average_data(q.series,'binsize',1,'nfft',nfft,'whole_bins',1);
            disp('average_data done')
            %
            % remove glitches
            %
            temp=find(log10(avg.AZ2)>-4.5);
            avg.EPSILON1(temp)=NaN;
            avg.EPSILON2(temp)=NaN;
            warning backtrace
            %
            % calc dynamic height
            %
            head=calc_dynamic_z(avg,head);
            %
            % create a seperate .mat data file containing 1m binned data and header
            %
            temp=num2str(q.script.num+10000);
            fn=[path_cham 'mat\' q.script.prefix temp(2:5)];
            head.p_max=max(cal.P);
            eval(['save ' fn ' avg head']);
        else
            names=fieldnames(avg);
            for ii=1:length(names)
                eval(['avg.' char(names(ii)) '(:) = NaN;'])
                head.dynamic_gz=NaN;
                head.direction='u';
            end
        end  % if bad~=1
        % add 1m binned data to the summary structure sum.
        add_to_sum
    end
catch
    add_bad_to_sum;
end
