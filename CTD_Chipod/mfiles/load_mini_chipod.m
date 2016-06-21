 function [data,the_time,counter]=load_mini_chipod(fname,startbyte,nblocks);

 % function to read the new mini_chipod data files that have 4 bytes per
 % line.
 % As of june 24, 2013, there is bad data in those files, so I needed to
 % fix this...  see below
 
if nargin<3
	nblocks=Inf;
end

if nargin <2
	startbyte=0;
end

fid = fopen(fname,'r','l');
if fid==-1
   disp('No file found...')
   data=[];head=[];
   return
end

epoch=datenum(1970,1,1);%reference time - times written in days since epoch
linesize=4;
if 1% Chipod2
   stat=fseek(fid,startbyte,-1);
   out=fread(fid,[linesize, nblocks], 'uint16=>double')';
end
fclose(fid);

counter_offset=find(out(1:101,1)==65535);
lenn=length(out(:,1));
counter_inds=counter_offset+[0:101:(lenn-counter_offset)];
% length(counter_inds)
% paus
% tmp=out(counter_inds,[2:3]);
% subplot(211)
% plot(tmp(:,1))
% subplot(212)
% plot(tmp(:,2))
% tmp(end,2)-tmp(1,2)
% size(out)
% lenn/101
% paus

%counter=epoch-16994+out(counter_inds,2)+out(counter_inds,3)/(24*3600);
counter=epoch+[out(counter_inds,3)+out(counter_inds,4)*2^16]/(24*3600);

%paus


%plot(counter-counter(1))
n_records=length(counter_inds);
partial_times=(ones(1,n_records)'*[0:99]/100/24/3600)';
base_times=(counter*ones(size([0:99])))';
%plot(reshape(partial_times,[prod(size(base_times)) 1]))

%the_time=[[(-(counter_offset-1):-1)/100/24/3600]'*0+counter(1) ; ...
%	reshape(partial_times+base_times,[prod(size(base_times)) 1])];

the_time=[[(-(counter_offset-1):-1)/100/24/3600]'+counter(1) ; ...
	reshape(partial_times+base_times,[prod(size(base_times)) 1])];



dat_inds=1:lenn;
dat_inds=setdiff(dat_inds,counter_inds);
data=out(dat_inds,:)/65535*4.098;

the_time=the_time(1:length(data(:,1)));
%date_0out(counter_offset