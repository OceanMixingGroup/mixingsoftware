function out=read_tsg_flowthrough(fname)
fid=fopen(fname);
data=textscan(fid,'%s',1e6,'delimiter','\r');
fclose(fid);
data=char(data{:});
ik=strmatch('META_DATA_PRECISION',data);
out.readme=data(1:ik,:);
tt=data(ik+1:end,:);

out.time=datenum(tt(:,7:16))+datenum(tt(:,18:29))-fix(datenum(tt(:,18:29)));
out.T=str2num(tt(:,33:38));
out.C=str2num(tt(:,41:47));
out.S=str2num(tt(:,50:56));
out.T(out.T<-2 | out.T>40)=NaN;
out.C(out.C<1 | out.C>4)=NaN;
out.S(out.S<10 | out.S>43)=NaN;

% tt(:,end+1)=',';
% frm='%s %s %f %f %f';
% data=textscan(tt',frm,size(tt,1),'delimiter',',','bufsize',1e6);
% tm=char(data{2});
% out.time=datenum(tm(:,1:10))+datenum(tm(:,12:23))-fix(datenum(tm(:,12:23)));
% out.T=data{3};
% out.C=data{4};
% out.S=data{5};
end % function out=read_tsg_bow(fname)

