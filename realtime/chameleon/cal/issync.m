function [data,bad]=issync(data,head)
% this function cuts raw data when sync is lost
% should be callaed from calibration routine (i.e. cali_ct01a.m)
% before doind anything else;
% aftewards check should be put into calibration script that
% cancels it if bad=0 (it means there is no sync data), i.e.
% [data,bad]=issync(data,head);
% if bad==1
%     return;
% end

bad=0;
bad1=[];
good=find(abs(diff(data.SYNC))>4.43 & abs(diff(data.SYNC))<4.53);
if any(good)
    if good(1)==1
        bad1=find(diff(good)~=1);
        if ~isempty(bad1)
            good=good(1:bad1(1));
        end
    else
        good=[];
    end
end
if any(good)
    good=[good;good(end)+1;good(end)+2];
    if length(good)<length(data.SYNC)
        names=fieldnames(data);
        for iii=1:length(names)
            eval(['data.' char(names(iii)) '=data.' char(names(iii)) ...
                    '(1:good(end)*head.irep.' char(names(iii)) ');']);
        end
    end
else
    bad=1;
    names=fieldnames(data);
    for iii=1:length(names)
        eval(['data.' char(names(iii)) '=[];']);
    end
end
