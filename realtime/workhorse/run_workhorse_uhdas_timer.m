% DOES NOT WORK!
attempt=0;
d=dirs(sprintf('%s%03d_*.raw',workhorsedir,trannum),'fullfile',1);
fname = sprintf('%s%03d_%s.raw',workhorsedir,trannum,num);
if fnum+1<=length(d)
    nextfile=sprintf('%s/%s_%03d_%02d_%s.mat',savedir,prefix,trannum,fnum+1,d(fnum+1).name(ff-5:ff-1));
else
    nextfile='000';
end
dd=dir(fname);
if dd.bytes>ddd && ~exist(nextfile,'file')
    attempt=attempt+1;
    ddd=dd.bytes;
    if dd.bytes>100000
        fname = sprintf('%s%03d_%s.raw',workhorsedir,trannum,num) %#ok<NOPTS>
        try
            if strcmpi(prefix,'wh300')
                data=get_xfraw(wh, fname, 'h_align',angle_offset);
                [data,config]=restruct(wh,data);
            elseif strcmpi(prefix,'os75')
                data=get_xfraw(wh, fname, 'h_align',angle_offset);
                [data,config]=restruct(os,data);
            end
        catch
            fprintf('Had trouble: %s\n',lasterr);
            fprintf('Pausing 20 seconds ...');
            for i=1:20
                pause(1);
            end
            if strcmpi(prefix,'wh300')
                data=get_xfraw(wh, fname, 'h_align',angle_offset);
                [data,config]=restruct(wh,data);
            elseif strcmpi(prefix,'os75')
                data=get_xfraw(wh, fname, 'h_align',angle_offset);
                [data,config]=restruct(os,data);
            end
        end
        adcp=uhdastosci(data);
        dt=mean(diff(adcp.time))*3600*24;
        npoints=round(averagetime/dt);
        fields=fieldnames(adcp);
        warning off
        for iii=1:length(fields)-2
            for kk=1:size(adcp.(char(fields(iii))),1)
                adc.(char(fields(iii)))(kk,:)=bindata1d...
                    ([1:npoints:length(adcp.time)+npoints],...
                    [1:length(adcp.time)],adcp.(char(fields(iii)))(kk,:));
            end
        end
        adc.depth=adcp.depth;
        adc.cfg=adcp.cfg;
        adcp=adc;
        savename = sprintf('%s/%s_%03d_%02d_%s.mat',savedir,prefix,trannum,fnum,num);
        save(savename,'adcp');
        clear adcp adc data config
        fclose all;
        
        fnum=fnum+1;attempt=0;
        num=d(fnum).name(ff-5:ff-1);
        ddd=0;
        
    end
    if attempt>1
        fprintf(1,'Pausing\n');
    end
else
    %         fname = sprintf('%s%03d_%s.raw',workhorsedir,trannum,num);
    d=dirs(sprintf('%s%03d_*.raw',workhorsedir,trannum),'fullfile',1);
    if length(d)>fnum % exist(fname)
        fnum=fnum+1;attempt=0;
        num=d(fnum).name(ff-5:ff-1);
        ddd=0;
    else
        fprintf(1,'Pausing\n');
    end
end

