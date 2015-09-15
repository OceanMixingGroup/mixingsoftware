function out=read_radiometer_03port(fname)
% disp(fname)
fid=fopen(fname);
data=textscan(fid,'%s',1e6,'delimiter','\r');
fclose(fid);
data=char(data{:});
ik=strmatch('META_DATA_PRECISION',data);
out.readme=data(1:ik,:);
out.readme=char('LW - computed longwave downwelling irradiance [W m^{-2}]',...
    'SW - computed shortwave downwelling irradiance [W m^{-2}]',out.readme);
tt=data(ik+1:end,:);
tt(:,end+1)=',';

frm='%s %s %s %s %s %f %f %f %f %f %f %f %s';
data=textscan(tt',frm,size(tt,1),'delimiter',',','bufsize',1e6);


%%% sally's additions
% not sure if this is exaxtly right, but I would do something like this. Also check that I have the right indices for the right kinds of files
if strcmp(char(data{3}(1)),'"$WIR02') == 1
    frm='%s %s %s %s %s %f %f %f %f %f %f %f %s';
    data=textscan(tt',frm,size(tt,1),'delimiter',',','bufsize',1e6);
    tm=char(data{2});
    if strcmp(tm(1,1),'"') == 1
        tm = tm(:,2:end-1);
    end
    out.time=datenum(tm(:,1:10))+datenum(tm(:,12:23))-fix(datenum(tm(:, ...
                                                  12:23)));    
    
    LW = data{8};
    SW = data{11};
    

else
    frm = '%s %s %s %s %s %s %s %s %s %s';
    data = textscan(tt',frm,size(tt,1),'delimiter',',','bufsize',1e6);
    
    tm=char(data{2});
    if strcmp(tm(1,1),'"') == 1
        tm = tm(:,2:end-1);
    end
    out.time=datenum(tm(:,1:10))+datenum(tm(:,12:23))-fix(datenum(tm(:,12:23))); 
    
    LW = char(data{5});
    indLW = find(LW == '"');
    LW(indLW) = ' ';
    for ii = 1:size(LW,1)
        if strcmp(LW(ii,2),' ')
            LW(ii,2:4) = 'NaN';
        end
    end
    LW = str2num(LW);
    
    SW = char(data{8});
    indSW = find(SW == '"');
    SW(indSW) = ' ';
    for ii = 1:size(SW,1)
        if strcmp(SW(ii,2),' ')
            SW(ii,2:4) = 'NaN';
        end
    end
    SW = str2num(SW);
    
%     SWstr = char(data{8});
%     if strcmp(LW(1,1),'"') == 1 
%        LW = LW(:,2:end-1);
%        LW = str2num(LW);
%        for mm = 1:length(LW)
%            ql = strfind(SWstr(mm,:),'"');
%            SW(mm) = str2num(SWstr(mm,ql(1)+1:ql(2)-1));
%        end
%        SW = SW';
%     end
end

   



%%% end sally's additions


if min(LW) < 0
    out.LW = -1*LW;
else
    out.LW = LW;
end
if min(SW) < 0;
   out.SW = -1*SW;
else
    out.SW = SW;
end

% out

end % function out=read_radiometer_metmast(fname)
