% plots a summary of the chameleon data.
% updated once in a while.  Should be run on a separate computer
% from the processing.  
figure(12)
maxdepth=get(fig.h(4),'string');
if (maxdepth(1)=='a' | maxdepth(1)=='A')
    max_depth=sum.depthmax;
else
    max_depth=abs(str2num(maxdepth));
    if length(max_depth)==0; max_depth=sum.depthmax; end
end

minfile=get(fig.h(5),'string');
if (minfile(1)=='a' | minfile(1)=='A')
    min_file=sum.castnumber(1);
else
    min_file=str2num(minfile);
    if length(min_file)==0; min_file=sum.castnumber(1); end
end

maxfile=get(fig.h(6),'string');
if (maxfile(1)=='a' | maxfile(1)=='A')
    max_file=sum.filemax;
else
    max_file=str2num(maxfile);
    if length(max_file)==0; max_file=sum.filemax; end
end
if max_file<=min_file
    min_file=max_file-1;
    disp('MIN X IS LARGER THAN MAX X!!!');
end

for jj=1:nplots
  bad=0;
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
      disp('MIN CCOLOR IS LARGER THAN MAX CCOLOR!!!');
  end
  h1=subplot(nplots,1,jj);
  posi=get(h1,'position');,posi(4)=posi(4)*1.2;,set(h1,'position',posi)
  eval(['dat = ' char(fig.toplot{jj}) ';']);
  ii=1:size(dat,2);
  if fig.ignoreups(jj)
    in=find(sum.direction(:)=='d');
    ii=ii(in);
  end;
  xx=sum.filenums+sum.filemin-1;
  toplot=[xx(ii) xx(ii(end))+1];
  dat=[dat(:,ii) dat(:,ii(end))];
  pcolor(toplot,-sum.depths,dat);
  caxis([colmin(jj) colmax(jj)]);
  shading flat
  colhand(jj)=colorbar;
  smallbar(h1,colhand(jj))
  if jj~=nplots
	set(gca,'xticklabel','')
  else
    xlabel(['Profile ' num2str(sum.filemax)],'fontsize',12);
  end
  if max_depth>4
      axis([min_file max_file+1 -max_depth-1 -0])
  else
      axis([min_file max_file+1 -6 -0])
  end    
  if bad==1
      t1=text((max_file-min_file)*.05+min_file,-max_depth*0.9,...
          'MAX is supposed to be larger then MIN!','fontsize',14);
  elseif bad==2
      t1=text((max_file-min_file)*.05+min_file,-max_depth*0.9,...
          'You''d better take some lessons of typing!','fontsize',14);
  end
  axes(colhand(jj));
  ylabel(char(fig.names(jj)),'fontsize',12)
end

