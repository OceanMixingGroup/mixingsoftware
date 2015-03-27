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
% frm='%s %s %s %s %s %f %f %f %f %f %f %f %s';
frm='%s %s %s %s %s %s %s %s %s %s';
data=textscan(tt',frm,size(tt,1),'delimiter',',');

% calculate time
tm=char(data{2});
if strcmp(tm(1,1),'"') == 1
    tm = tm(:,2:end-1);
end
timeall=datenum(tm(:,1:10))+datenum(tm(:,12:23))-fix(datenum(tm(:,12:23)));

% now get the data
LW1 = char(data{5});
LW2 = LW1(:,2:end);
indgoodLW = find(LW2(:,1) ~= '"');
LW3 = LW2(indgoodLW,:);
for ii = 1:size(LW3,1)
    ind = find(LW3(ii,:) == '"');
    LW3(ii,ind) = ' ';
end
out.LW = str2num(LW3);

SW1 = char(data{8});
SW2 = SW1(:,2:end);
indgoodSW = find(SW2(:,1) ~= '"');
SW3 = SW2(indgoodSW,:);
for ii = 1:size(SW3,1)
    ind = find(SW3(ii,:) == '"');
    SW3(ii,ind) = ' ';
end
out.SW = str2num(SW3);

out.time = timeall(indgoodSW);

% % % check that the longwave and shortwave indices are the same
% % if length(indgoodLW) == length(indgoodSW)
% %     diffind = indgoodLW - indgoodSW;
% %     badpts = find(diffind ~= 0);
% %     if isempty(badpts)
% %         out.time = timeall(indgoodLW);
% %     else
% %         disp(['radiometer issue: ' fname])
% %     end
% % end


end % function out=read_radiometer_metmast(fname)

