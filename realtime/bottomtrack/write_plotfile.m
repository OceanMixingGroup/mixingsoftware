
info.zup = str2num(get(plotinfo.zup,'string'));
info.zdown = str2num(get(plotinfo.zdown,'string'));
info.lleft = str2num(get(plotinfo.lleft,'string'));
info.lright = str2num(get(plotinfo.lright,'string'));
infoout = [info.zup info.zdown info.lleft info.lright];
% info.surveyname = plotinfo.surveyname;
save(fname_plotinfo,'infoout','-ascii');
