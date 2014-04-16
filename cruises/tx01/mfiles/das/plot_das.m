
load das;

subplot(4,1,1);
plot(das.datenum,das.lon,'.');
datetick;
grid on;

subplot(4,1,2);
plot(das.datenum,das.ft_temp,'.');
set(gca,'ylim',[7 16]);
grid on;
datetick;

subplot(4,1,3);
plot(das.datenum,das.ft_sal,'.');
set(gca,'ylim',[30 34]);
datetick;
grid on;

das.sigmat=sw_pden(das.ft_sal,das.ft_temp,3,0);

subplot(4,1,4);
plot(das.datenum,das.sigmat,'.');
set(gca,'ylim',[1022 1026]);
grid on;

datetick;


