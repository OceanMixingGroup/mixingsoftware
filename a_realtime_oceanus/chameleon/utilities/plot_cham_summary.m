% plot_cham_summary.m
%
% notes added by sjw, January 2014
%
% This code is called within the timer by show_chameleon_timer after the 
% initial plot is made to add subsequent data.


% calls the figure made by show_chameleon_timer
figure(12)

% The first time this code is run, most likely maxdepth='all' and it needs 
% to be set to the actual max depth. For subsequent times that this code is
% run, maxdepth already is set to the maximum depth, unless the newest data
% is deeper than any previous data.
maxdepth=get(fig.h(4),'string');
if (maxdepth(1)=='a' | maxdepth(1)=='A')
    max_depth=cham.depthmax;
else
    max_depth=abs(str2num(maxdepth));
    if length(max_depth)==0; max_depth=cham.depthmax; end
end

% minfile is the cast-number that is first contained in the summary file.
% Also need to convert min_file to minfile.
minfile=get(fig.h(5),'string');
if (minfile(1)=='a' | minfile(1)=='A')
    min_file=cham.castnumber(1);
else
    min_file=str2num(minfile);
    if length(min_file)==0; min_file=cham.castnumber(1); end
end

% maxfile is the cast-number that is last contained in the summary file.
% Also need to convert max_file to maxfile.
maxfile=get(fig.h(6),'string');
if (maxfile(1)=='a' | maxfile(1)=='A')
    max_file=cham.filemax;
else
    max_file=str2num(maxfile);
    if length(max_file)==0; max_file=cham.filemax; end
end
if max_file<=min_file
    min_file=max_file-1;
    disp('MIN X is larger than MAX X');
end


% loop through the subplots to replot the data. If there is new data in the
% summary file, it will show up in the plot.
for jj=1:nplots
    
    % define a variable 'bad' which is used as a flag in case the incoming
    % data is not good or an error is made.
    bad=0;
    
    % determine the limits of the color axis for the jjth subplot. First it
    % reads the min and max from the data in show_chameleon_timer. Then new
    % variables colmax and colmin are created, which get overwritten if the
    % color limits have been changed using the gui interface on the plot
    % and are different from the original setting.
    cmax=str2num(get(fig.h3(jj),'string'));
    if length(cmax)==0
        bad=2; colmax(jj)=fig.colmax(jj);
    else
        colmax(jj)=cmax;
    end
    cmin=str2num(get(fig.h4(jj),'string'));
    if length(cmin)==0
        bad=2; colmin(jj)=fig.colmin(jj);
    else
        colmin(jj)=cmin;    
    end
    if colmax(jj)<=colmin(jj)
        bad=1;
        colmin(jj)=colmax(jj)-0.5*abs(colmax(jj));
        disp('MIN CCOLOR is larger than MAX CCOLOR');
    end
    
    
    % get the handle of the jjth subplot. Set its fontsize and position
    h1=subplot(nplots,1,jj);set(h1,'fontsize',fs);
    sp=get(h1,'position'); set(h1,'position',[sp(1) sp(2) sp(3)-0.05 sp(4)]);
    posi=get(h1,'position');,posi(4)=posi(4)*1.2;,set(h1,'position',posi);
    
    % call correct data for this particular subplot 'dat'
    eval(['dat = ' char(fig.toplot{jj}) ';']);
    
    % ii is the number of casts to be plotted (i.e. the length of the data
    % along the x-axis). Only plot the down-casts.
    ii=1:size(dat,2);
    in=find(cham.direction(:)=='d');
    ii=ii(in);

    % define an index of the proper casts to plot and append dat as needed
    xx=cham.castnumber;
    toplot=[xx(ii) xx(ii(end))+1];
    dat=[dat(:,ii) dat(:,ii(end))];
    
    % pcolor the data. set the correct color limits. Color limits are set
    % in set_chameleon at start of this code.
    pcolor(toplot,-cham.depth,dat);
    shading flat
    caxis([colmin(jj) colmax(jj)]);
    
    % add a colorbar. Give it the correct font size and make it skinny.
    colhand(jj)=colorbar; set(colhand(jj),'fontsize',fs);
    smallbar(h1,colhand(jj));
    cpi=get(colhand(jj),'position');spi=get(h1,'position');
    cpi(1) = cpi(1)+0.09;
    if jj>1
        set(h1,'position',[spf(1) spi(2) spf(3) spf(4)]);
        set(colhand(jj),'position',[cpf(1) spi(2) cpf(3) spf(4)]);
    else
        set(colhand(jj),'position',[cpi(1) spi(2) cpi(3) spi(4)]);
    end
    spf=get(h1,'position');  cpf=get(colhand(jj),'position');
    
    % add an x-label to the bottom subplot
    if jj~=nplots
        set(gca,'xticklabel','')
    else
        xlabel(['Profile ' num2str(cham.filemax)],'fontsize',fs);
    end
    
    % make sure the x and y-axes have the correct limits 
    if max_depth>4
        axis([min_file max_file+1 -max_depth-1 0])
    else
        axis([min_file max_file+1 -6 0])
    end    
    if bad==1
        t1=text((max_file-min_file)*.05+min_file,-max_depth*0.9,...
            'MAX smaller than MIN','fontsize',fs);
    elseif bad==2
        t1=text((max_file-min_file)*.05+min_file,-max_depth*0.9,...
            'Wrong again... Try once more.','fontsize',fs);
    end

    % add the correct y-label
    ylabel(colhand(jj),char(fig.names(jj)),'fontsize',fs)
    
    % make sure the font size of the axis is correct
    set(gca,'fontsize',fs)
end

