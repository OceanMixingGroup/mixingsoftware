function out=read_radiometer_metmast(fname)
fid=fopen(fname);
% disp(fname)
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
    data = textscan(tt',frm,size(tt,1),'delimiter',',','bufsize', 1e6);
    
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
    
    
%     
%     LWstr = char(data{5});
%     SWstr = char(data{8});
%     
% 	if strcmp(LWstr(1,1),'"') == 1 
%         LWstr = LWstr(:,2:end-1);
%         SWstr = SWstr(:,2:end-1);
%         
%         if isempty(SWstr) & isempty(LWstr)
%             LW = NaN*out.time;
%             SW = NaN*out.time;
%             out.LW = NaN*out.time;
%             out.SW = NaN*out.time;
%         elseif size(SWstr,1) < 2
%             LW = NaN*out.time;
%             SW = NaN*out.time;
%             out.LW = NaN*out.time;
%             out.SW = NaN*out.time;
%         
%             
%         else
%         
% %             for jj = 1:size(SWstr,1)
% %                 if strcmp(SWstr(jj,end),'"')
% %                     SWstr2(jj,:) = [SWstr(jj,1:end-1) '0'];
% %                 else
% %                     SWstr2(jj,:) = SWstr(jj,:);
% %                 end
% %             end
%             
%             ind = find(SWstr == '"');
%             SWstr(ind) = ' ';
%      
%             if strcmp(LWstr(2,1),'"') == 1 || strcmp(LWstr(1,1),'"') == 1
%                 for jj = 1:size(LWstr,1)
%                     if strcmp(LWstr(jj,1),'"') ~= 1
%                         indgood(jj) = 1;
%                     else
%                         indgood(jj) = 0;
%                     end     
%                 end
%                 indgood = logical(indgood);
%                 LW = str2num(LWstr(indgood,:));
%                 SW = str2num(SWstr(indgood,:));
%                 out.time = out.time(indgood);
%             else
%                 LW = str2num(LWstr);
%                 SW = str2num(SWstr);
%             end
%         end
%     end
end






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
