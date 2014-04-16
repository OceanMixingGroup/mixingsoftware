function combine_tao_data(datadir,moor)
% combine_tao_data.m
% combines all processed tao data for the particular mooring
% datadir is location of the processed *.mat files
% and moor is the mooring position, e.g moor='0n110w';

d=dir([datadir '*' moor '*.mat']);
for i=1:length(d)
    load([datadir d(i).name]);
end
if exist('adcp','var'); tao.adcp=adcp; end
if exist('bp','var'); tao.bp=bp; end
if exist('cur','var'); tao.cur=cur; end
if exist('sigma','var'); tao.sigma=sigma; end
if exist('met','var'); tao.met=met; end
if exist('rain','var'); tao.rain=rain; end
if exist('sal','var'); tao.sal=sal; end
if exist('t','var'); tao.t=t; end
if exist('rad','var'); tao.rad=rad; end
if exist('lw','var'); tao.lw=lw; end
save([datadir '\tao' moor],'tao') 
