% plot marliin/ seabird data

ps=input('enter start profile -->  ');
pf=input('enter end profile -->  ');

plot(marlin.ptime,1.82*(marlin.t1-mean(marlin.t1(isnan(marlin.t1)==0))), ...
   sbd.ptime,sbd.temp-mean(sbd.temp),'r');grid

axis([ps pf -1 3])
