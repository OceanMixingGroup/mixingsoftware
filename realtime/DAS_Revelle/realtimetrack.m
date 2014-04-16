% realtimetrack.m
% read raw DAS files from ship server,
% convert them to .mat files (use readdas_ct03.m)
% display underway data (use PlotRealTimeTrack.m)
% and backup it
clear all;
set_DAS;
dirdata=dir([rawpath '*.cor']);
lendirdata=length(dirdata);
while 1
    try
    dirdata=dir([rawpath '*.cor']);
    if length(dirdata)==lendirdata
        datafile=dirdata(end).name;
        ttrack=[];
        trackname = [trackpath  datafile];
        track=readdas_ct03([rawpath datafile]);
        PlotRealTimeTrack(track);
        print('-djpeg85','-r250',[figpath datafile(1:6)]);
        save(trackname(1:end-4),'track');
        lendirdata=length(dirdata);
    else 
        datafile=dirdata(end-1).name;
        ttrack=[];
        trackname = [trackpath  datafile];
        track=readdas_ct03([rawpath datafile]);
        PlotRealTimeTrack(track);
        print('-djpeg85','-r250',[figpath datafile(1:6)]);
        save(trackname,'track');
        copyfile([rawpath datafile],[backuppath datafile]);
        datafile=dirdata(end).name;
        ttrack=[];
        trackname = [trackpath  datafile];
        track=readdas_ct03([rawpath datafile]);
        PlotRealTimeTrack(track);
        print('-djpeg85','-r250',[figpath datafile(1:6)]);
        save(trackname,'track');
        lendirdata=length(dirdata);
    end
    catch
        for i=1:60
            disp('File in use. Pausing...')
            pause(1);
        end
    end
    for i=1:60
        disp('Pausing...')
        pause(30);
    end
end

