function big=load_chipod_data(the_path,time_range,suffix,isbig);

if nargin<4
isbig=1; % presume it is a big chipod	
end

%	the_path='../data/A16S/Ti_RBR_Chipod_Downlooker/';
%the_path='../data/A16S/Ti_RBR_Chipod_Uplooker/';
%suffix='mlg';
%isbig=0;
%the_path='../data/A16S/Chipod_CTD/';
%suffix='1002';
%isbig=1;

% load appropriate chipod data (not quite sure how to do this efficiently?)
% Hardwire for the time being. 

the_files=dir([the_path '/*.' suffix])
t_extra=2;
if isbig==1
	t_extra=24;
end
nfiles=length(the_files);
big=[]
for a=1:nfiles
	fname=the_files(a).name;
	time_inds=findstr(fname,'.')+[-8:-1];
	file_time=fname(time_inds);
	
	if datenum(file_time,'yymmddhh')>(time_range(1)-t_extra/24) & datenum(file_time,'yymmddhh')<(time_range(2)+t_extra/24)
		% we've got the right file, so let's load it.
		fname=[the_path the_files(a).name]
		try
			if isbig
			[data head]=raw_load_chipod(fname);
			chidat.datenum=data.datenum;
			len=length(data.datenum);
			if mod(len,2)
				len=len-1; % for some reason datenum is odd!
			end
			chidat.T1=makelen(data.T1(1:(len/2)),len);
			chidat.T1P=data.T1P;
			chidat.T2=makelen(data.T2(1:(len/2)),len);
			chidat.T2P=data.T2P;
			chidat.AX=makelen(data.AX(1:(len/2)),len);
			chidat.AY=makelen(data.AY(1:(len/2)),len);
			chidat.AZ=makelen(data.AZ(1:(len/2)),len)
		else
			% its a minichipod
           
			try
				[out,counter]=load_mini_chipod(fname);
			catch
				try
					[out,counter]=load_mini_chipod(fname,8400);
				catch
				end
			end
			chidat.datenum=counter;
			chidat.T1=out(:,2);
			chidat.T1P=out(:,1);
			chidat.AX=3*out(:,4);
			chidat.AZ=3*out(:,3);
%			plot(chidat.datenum,chidat.T1);
%			hold on

		end
		big=mergefields_jn(big,chidat,1,1);
		catch
		end
		%	else
		% do nothing.
	end
	
end
if isempty(big)
	big.datenum=NaN;
end
%datestr([big.datenum(1) big.datenum(end)])
ginds=find(big.datenum>time_range(1) & big.datenum<time_range(2));
length(ginds)
fnames=fieldnames(big);
for a=1:length(fnames)
	big.(fnames{a})=big.(fnames{a})(ginds);
end


doplots=0;
if doplots
subplot(311)
plot(big.datenum,big.T1);
title(datestr(mean(chidat.datenum)))
axis tight
xlim(time_range)
kdatetick
subplot(312)
plot(big.datenum,big.T1P);
title(datestr(mean(chidat.datenum)))
axis tight
xlim(time_range)
kdatetick
subplot(313)
plot(big.datenum,big.AX,big.datenum,big.AZ);
axis tight
xlim(time_range)
kdatetick
end

%print -dpng -r300 case5.png
