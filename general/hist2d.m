function [hist,mn,mdn,md]=hist2d(timebins,valuebins,timein,timelogbool,signalin,signallogbool,normal);
%function [hist,mn,mdn,md]=hist2d(timebins,valuebins,timein,timelogbool,signalin,signallogbool,normal);
%timebins - bins for x axis (or independent variable)
%valuebins - bins for y axis (or dependent variable)
%timein - independent variable time series
%timelogbool - 1 or 0, should pdf of independent variable be done in log space(1) or linear space(0)
%signalin - dependent variable time series
%signallogbool- 1 or 0, should pdf of dependent variable be done in log space(1) or linear space(0)
%normal - integer (0,1,2,3) - if 0, do not scale pdf.  If 1, normalize pdf
%by number of realizations along x axis (normalize n vertical one-d-pdf).  If 2, normalize pdf by number of realizations along y axis
%(normalize m horizontal one-d-pdfs).  If 3, normalize 2d-pdf by total
%number of realizations.
%
% Example to plot data:
% h=pcolor(timebins,valuebins,hist)
% set(h,'edgecolor','none')
% colormap(flipud(hot))
%
%
%------------------------
% 01/26/16 - A.Pickering - Make function name same as file, and plotting
% example
%%
Lt=length(timebins);
Lv=length(valuebins);

hist(1:Lt,1:Lv)=0;

delLt=.5*(timebins(2)-timebins(1));

delLv=.5*(valuebins(2)-valuebins(1));

if timelogbool 
    time=log10(timein);
else
    time=timein;
end

if signallogbool
    signal=log10(signalin);
else
    signal=signalin;
end


for m=1:Lt
    
    beg_time=timebins(m)-delLt;
    end_time=timebins(m)+delLt;
    
    ind=find(time>=beg_time&time<end_time);
    
    for n=1:Lv
        
        beg_val=valuebins(n)-delLv;
        end_val=valuebins(n)+delLv;
        
        count=find(signal(ind)>=beg_val&signal(ind)<end_val);
        
        hist(m,n)=length(count);
    end
    
    
    out=signalin(ind);
    ind=find(~isnan(out));
    if length(out(ind))==0
        out=NaN;
        ind=1;
    end
    
    mn(m)=mean(out(ind));
    mdn(m)=median(out(ind));
    temp=max(hist(m,:));
    
    if temp>0
        temp=find(hist(m,:)==temp);
        temp=round(mean(temp));
        md(m)=temp;
    else
        md(m)=NaN;
    end
    
    md(m)=interp1([1:Lv],valuebins,md(m));
    
end

if normal==3;
    ind=find(~isnan(hist));
    tot=sum(hist(ind));
    hist=hist./tot;
elseif normal==2;
    for n=1:Lv;
        ind=find(~isnan(hist(:,n)));
        tot=sum(hist(ind,n));
        hist(:,n)=hist(:,n)./tot;
    end
elseif normal==1;
    for m=1:Lt;
        ind=find(~isnan(hist(m,:)));
        tot=sum(hist(m,ind));
        hist(m,:)=hist(m,:)./tot;
    end
end
hist=hist';

        
    
    