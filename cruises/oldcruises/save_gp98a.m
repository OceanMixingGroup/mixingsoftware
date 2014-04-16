ipl=0;% counter
%for iprof=[5 7 9 11 12 14:2:26 27 29:43 46:75];
for iprof=[72];
prf=num2str(iprof+1000);
q.script.num=iprof;
q.script.prefix='gp98a';
q.script.pathname='r:\Data\Gp98a\';
clear cal data

raw_load

cal_gp98a

%do other stuff
 
cal_3p
plot_u

%counter for plot_tilt layout
%ipl=ipl+1;
%plot_tilts

pause(4)
end
