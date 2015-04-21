
vol = '/Volumes/NASH_MACBAK/home/nash/Data/IWISE10/CTD/';
dirlist = dir([vol 'IWISE10*.hex']);
cfgload001

for i=247:length(dirlist)
    ctdname = dirlist(i).name;
    d = hex_read([vol ctdname]);
    data1 = hex_parse(d);
    
    data2 = physicalunits(data1, cfg);

    [pm,ii]=max(data2.p);
    ij = find(data2.p>pm-100 & data2.p <pm+100);

    figure;
    [ax,f1,f2]=plotyy(data2.time(ij),data2.p(ij),data2.time(ij),data1.ch4(ij)); 
    set(f2,'color','r','linewidth',1); 
    set(f1,'color','w','linewidth',1); 
    set(get(ax(1),'Ylabel'),'String','Pressure'); 
    set(get(ax(2),'Ylabel'),'String','Altimeter (m)'); 
    set(ax(2),'YColor','r'); 
    set(ax(1),'YColor','w'); 
    title([dirlist(i).name]);
    print('-djpeg',['bottom/bot_' num2str(i) '.jpg'])
    close;
end
