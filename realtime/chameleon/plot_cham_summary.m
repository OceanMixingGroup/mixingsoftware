% plot_cham_summary.m
figure(12)
maxdepth=get(fig.h(4),'string');
if (maxdepth(1)=='a' | maxdepth(1)=='A')
    max_depth=cham.depthmax;
else
    max_depth=abs(str2num(maxdepth));
    if length(max_depth)==0; max_depth=cham.depthmax; end
end

minfile=get(fig.h(5),'string');
if (minfile(1)=='a' | minfile(1)=='A')
    min_file=cham.castnumber(1);
else
    min_file=str2num(minfile);
    if length(min_file)==0; min_file=cham.castnumber(1); end
end

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
      disp('MIN CCOLOR is larger than MAX CCOLOR');
  end
  h1=subplot(nplots,1,jj);set(h1,'fontsize',8);
  sp=get(h1,'position'); set(h1,'position',[sp(1) sp(2) sp(3)-0.05 sp(4)]);
  posi=get(h1,'position');,posi(4)=posi(4)*1.2;,set(h1,'position',posi);
  eval(['dat = ' char(fig.toplot{jj}) ';']);
  ii=1:size(dat,2);
  in=find(cham.direction(:)=='d');
  ii=ii(in);
%   xx=cham.filenums+cham.filemin-1;
  xx=cham.castnumber;
  toplot=[xx(ii) xx(ii(end))+1];
  dat=[dat(:,ii) dat(:,ii(end))];
  pcolor(toplot,-cham.depth,dat);
  caxis([colmin(jj) colmax(jj)]);
  shading flat
  colhand(jj)=colorbar; set(colhand(jj),'fontsize',8);
  smallbar(h1,colhand(jj));
  cpi=get(colhand(jj),'position');spi=get(h1,'position');
  if jj>1
    set(h1,'position',[spf(1) spi(2) spf(3) spf(4)]);
    set(colhand(jj),'position',[cpf(1) spi(2) cpf(3) spf(4)]);
  else
    set(colhand(jj),'position',[cpi(1) spi(2) cpi(3) spi(4)]);
  end
  spf=get(h1,'position');  cpf=get(colhand(jj),'position');
  if jj~=nplots
	set(gca,'xticklabel','')
  else
    xlabel(['Profile ' num2str(cham.filemax)],'fontsize',9);
  end
  if max_depth>4
      axis([min_file max_file+1 -max_depth-1 0])
  else
      axis([min_file max_file+1 -6 0])
  end    
  if bad==1
      t1=text((max_file-min_file)*.05+min_file,-max_depth*0.9,...
          'MAX smaller than MIN','fontsize',10);
  elseif bad==2
      t1=text((max_file-min_file)*.05+min_file,-max_depth*0.9,...
          'Wrong again... Try once more.','fontsize',10);
  end
%   axes(colhand(jj));
  ylabel(colhand(jj),char(fig.names(jj)),'fontsize',9)
end

