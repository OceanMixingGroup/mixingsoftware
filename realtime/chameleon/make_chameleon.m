% save_files.m
clear all; close all; fclose all;
% cd c:\work\eq08\mfiles\chameleon
initialize_summary_file;
n=0;
load nextfile;
figure(1);
temp=get(0,'ScreenSize');
% posi=[0 -52 temp(3)/2 temp(4)-7]; 
posi=[0 0 temp(3)/3.5 temp(4)/6]; 
set(gcf,'position',posi)
clf
fig.h(1)=uicontrol('units','normalized','position',[0 0 1 1],...
    'string','Stop Chameleon','fontunits','normalized','fontsize',0.2,...
    'callback','kill_script=1');
kill_script=0;
while kill_script==0
    try
        load_file=[q.script.pathname q.script.prefix sprintf('%04.3f',nextfile/1000)]
        next_file=[q.script.pathname q.script.prefix sprintf('%04.3f',(nextfile+1)/1000)];
        if exist(next_file,'file')
            disp(['processing file ' load_file])
            q.script.num=nextfile;
%             q.script.num
            nextfile=nextfile+1;
            save nextfile nextfile
            process_file
        end
    catch
        add_bad_to_sum;
    end
    for i=1:wait;
        if kill_script==0
            pause(1)
            fprintf(1,'.');
        else
            return;
        end
    end
end
