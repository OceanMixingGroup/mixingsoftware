function [] = print_fancy_figure(fig,path,fid,format)
% prints a fancy figure either in eps, pdf or png

    set(fig,'PaperPositionMode','auto')
    %set(fig,'fontname','AvantGarde')

    if(format=='eps')
        export_fig([path fid],'-eps','-painters',fig);
    elseif(format=='pdf')
        export_fig([path fid],'-pdf','-painters',fig);
    elseif(format=='png')
	export_fig([path fid],'-png','-painters','-r100',fig);
    elseif(format=='png400')
        export_fig([path fid],'-png','-painters','-r400',fig);
    else
        error('wrong format (choose between eps,pdf,png)');
    end


end
