% make_workhorse_uhdas.m
% read short or long term averaged files using read_workhorse.m
% (read_surveyor.m), translates data to useful format (workhorsetosci.m)
% and saves mat files with adcp data
      % vel1: to EAST
      % vel2: to NORTH
      % vel3: to SURFACE
      % vel4: ERROR velocity
      % time1: computer time
      % time2: ADCP internal clock
      % navfirsttime, navlasttime: GPS time
clear all;
% adcppath
% radcppath
prefix=input('Enter ADCP type (''wh300'' or ''os75'') --> ');
set_workhorse;
trannum=input('Enter daynam --> ');

d=dirs(sprintf('%s%03d_*.raw',workhorsedir,trannum),'fullfile',1);
  
while isempty(d)
   disp('No data... Waiting...')
   for i=1:120
     pause(1)
   end;
   d=dirs(sprintf('%s%03d_*.raw',workhorsedir,trannum),'fullfile',1);
end
sd=dir(sprintf('%s%s*.mat',savedir,prefix));
ff=find(d(1).name=='.',1,'last');
num=d(1).name(ff-5:ff-1);
cfg=[];
clear adcp;
% savename = sprintf('%s/%s%03d%s.mat',savedir,prefix,trannum,type_of_average);
ddd=0;
figure(2);
temp=get(0,'ScreenSize');
% posi=[0 -52 temp(3)/2 temp(4)-7]; 
posi=[temp(3)-temp(3)/3.5 0 temp(3)/3.5 temp(4)/6]; 
set(gcf,'position',posi)
clf
fig.h(1)=uicontrol('units','normalized','position',[0 0 1 1],...
    'string','Stop ADCP','fontunits','normalized','fontsize',0.2,...
    'callback','kill_script=1');
kill_script=0;
fnum=1;
attempt=0;
while kill_script==0
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
        end
        if attempt>1
            fprintf(1,'Pausing\n');
            for i=1:waittime
                if kill_script==0
                    pause(1)
                    if i==round(i/10)*10
                        fprintf(1,'.');
                    end
                else
                    return;
                end
            end;
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
            for i=1:waittime
                if kill_script==0
                    pause(1)
                    if i==round(i/10)*10
                        fprintf(1,'.');
                    end
                else
                    return;
                end
            end;
        end
    end
end
