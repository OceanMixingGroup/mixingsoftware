function [] = retick(ax)
%set new Ticks on the position of the old tick
%[] = retick(ax)

n=length(ax);

for i=1:n
    yl=get(ax(i),'Ylim');
    xl=get(ax(i),'xlim');
    pos=get(ax(i),'Position');
    xt=get(ax(i),'Xtick');
    yt=get(ax(i),'Ytick');
    
    a=axes('Position',pos,'Color','none','Xticklabel',{},'Yticklabel',{},'Ylim',yl,'Xlim',xl,'Ytick',yt,'XTick',xt);
    box(a,'on');
    
end

