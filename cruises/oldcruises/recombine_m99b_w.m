% script to read marlin mat files and string together as 1 file
iprof=[2101:2448];
[lx ly]=size(iprof);
time_avg=1;
ll=ly*320/time_avg; % factor to presize the arrays
time=nan*ones(1,ll);
ptime=nan*ones(1,ll);
w1var=nan*ones(1,ll);

icnt=0;

fout=['d:\data\m99b\marlin\tow07\summary_files\m99b_w_',num2str(iprof(1)),'_',num2str(iprof(end))];

for ip=iprof
   fname=['d:\data\m99b\marlin\tow07\mat_files\m99b_w_',num2str(ip),'.mat'];
   if exist(fname) ~= 0
   eval(['load ' fname])
   disp(fname)
   
   
% find length of data set
len=length(avg.TIME);
icnt=icnt+len;

% make arrays
time(icnt-len+1:icnt)=avg.TIME;
ptime(icnt-len+1:icnt)=avg.PTIME;
w1var(icnt-len+1:icnt)=avg.W1VAR;

end

end

eval(['save ' fout ' time ptime w1var'])
