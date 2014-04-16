
set(gcf,'windowbuttonmotionfcn','')
probe_stuff=setstr(32*ones(head.num_sensors+6,88));
spacs=char(32*ones(head.num_sensors,1));
%spacs=[' ';' ';' ';' ';' ';' ';' ';' ';' ';' ';' ';' ';' ';' ';' ';' '];
probe_stuff(1,1:27)=['   Filename: ' head.filename];
probe_stuff(2,1:29)=[' Instrument: ' head.instrument];
probe_stuff(3,1:77)=[sprintf('   Baudrate: %8.1f     Start Depth: %9.3f ', head.baudrate, head.startdepth) ...
      '  Start ' head.starttime]  ;
probe_stuff(4,1:77)=[sprintf(' Samplerate: %8.1f       End Depth: %9.3f ', head.samplerate, head.enddepth) ...
      '    End ' head.endtime]  ;
probe_stuff(6,1:88)=['Name     Id       Module  Filt  Ch  Of  M       A' ...
		    '        B         C         D      Gain'];
for a=1:head.num_sensors
  eval(['tmp=head.coef.' head.sensor_name(a,:) ';'])
  xx=sprintf(' %11.5f %11.5f %11.5f %11.5f %11.5f',tmp);
  coefs(a,1:length(xx))=xx;
end
temp=[head.sensor_name(:,1:8) spacs head.sensor_id(:,1:8) spacs head.module_num(:,1:8) ...
      spacs num2str(head.filter_freq) spacs num2str(head.das_channel_num) ...
      spacs num2str(head.offset) spacs num2str(head.modulas) ...
      coefs];
a=size(temp);
probe_stuff(7:6+a(1),1:a(2))=temp;
h.header=uicontrol('style','text','units','normalized','position',[.02 .02 .96 ...
      .8],'string',probe_stuff, 'horizontalalignment','left','fontname',q.font, 'fontsize',q.fsize);
h.header2=uicontrol('style','push','string','CLOSE','units','normalized','position',[.42 .03 ...
      .16 .05],'backgroundcolor',[.8 .80 .80],'callback','delete(h.header);,delete(h.header2);,set(gcf,''windowbuttonmotionfcn'',''qv_updat'')');
