function addcmap(hn,cmap,ho,z)
% ADDCMAP(HN,CMAPNEW,HO) takes a figure with multiple color plots and
% adds a new colormap CMAPNEW to the plots specified by the handles HN,
% while adjusting the plots with handles HO to look the same as they did
% prior to running ADDCMAP.
% 
% ADDCMAP works equally well for CONTOURF, PCOLOR and IMAGESC plots (I
% haven't tested anything else).
% 
% HN (new handles) should be an array of handles to the plots (not the
% axes) whos colormaps you wish to change to CMAPNEW.
% 
% HO (old handles) should be an array of handles to the plots whos
% colormaps you do not want to change.
% 
%%%%%%%%%%%%
% THE FORM:
% ADDCMAP(...,CBARH) will modify the colorbars to match the new
% colormap.  CBARH must be length N, and have a 1-to-1 correspondence to
% the plots that are changing.  If more than one plot corresonds to a
% given colorbar, simply repeat the handle to that colorbar appropriately
% in CBARH.
% 
%%%%%%%%%%%
% IMPORTANT NOTES:
% 1) use ADDCMAP only AFTER you have finished plotting all data.
% If you plot data AFTER using addcmap, you will have to adjust the
% limits of that new axes appropriately.
% 2) You MUST reinitialize the colormap in a figure before using
% addcmap.  Looping addcmap many times can result in memory problems.
% 3) Use the form "jet(128)" or "bone(256)", as inputs to addcmap,
% otherwise memory problems can occur.
% 
%%%%%%%%%%%%%%%%%%
% Example:
% 
% clf
% colormap(jet(128));
% 
% h.axes(1)=subplot(3,1,1);
% h.plot(1)=pcolor(peaks);
% shading flat
% h.cbar(1)=colorbar;
% 
% load flujet
% h.axes(3)=subplot(3,1,3);
% h.plot(3)=imagesc(X)
% h.cbar(3)=colorbar;
% 
% addcmap(h.plot(1),winter(128),h.plot(2),h.cbar(1));
  


hn=hn(:);
ho=ho(:);

if strcmp(get(hn,'type'),'hggroup')
  ncnt=strcmp(get(hn,'type'),'hggroup');
  ocnt=strcmp(get(ho,'type'),'hggroup');
  [srcn{find(ncnt)}]=deal('Zdata');
  [srco{find(ocnt)}]=deal('Zdata');
else
  [srco{1:length(ho)}]=deal('Cdata');
  [srcn{1:length(hn)}]=deal('Cdata');
end

for ii=1:length(ho)
  if exist('ocnt','var') && ocnt(ii)
    ls{ii}=get(ho(ii),'linestyle');
  end
end

cmap_old=get(get(get(hn(1),'parent'),'parent'),'colormap');
% Determine if we are going to fix any colorbars:
if nargin>3 && all(ishandle(z))
  cbarflag=1;
  cbars_new=z;
else
  cbarflag=0;
end
if length(hn)>1
  axes_new=cell2mat(get(hn,'parent'));
else
  axes_new=get(hn,'parent');
end
if length(ho)>1
  axes_old=cell2mat(get(ho,'parent'));
else
  axes_old=get(ho,'parent');
end
axes_all=[axes_new;axes_old];

for i0=1:length(axes_new)
  ax_newpos(i0,:)=get(axes_new(i0),'position');
end

cmap_all=[cmap_old;cmap];
lencmap_old=length(cmap_old);
lencmap_new=length(cmap);
lencmap_all=lencmap_new+lencmap_old;
prnts=cell2mat(get(axes_all,'Parent'));

% Check to make sure that all of the axes are in the same figure.
if ~all(prnts==prnts(1))
  error('All objects must be in the same figure.')
else
  cf=prnts(1);
end
% Set the new colormap:
set(cf,'colormap',cmap_all);

% New map loop:
for ii=1:length(hn)
  % Fix data to be plotted with the new colormap:
  if cbarflag
    if size(get(findobj(cbars_new(ii),'type','image'),'Cdata'),1)==1
      direc='x';
    else
      direc='y';
    end
    clims(ii,:)=get(cbars_new(ii),[direc 'lim']);
  else
    ud=get(axes_new(ii),'UserData');
    icl=find(strcmp(ud,'clim'))+1;
    if ~isempty(icl)
      clims=ud{icl}
    else
      clims=get(axes_old(ii),'clim');
    end
%    clims(ii,:)=z(ii,:);
  end
  cdata=get(hn(ii),srcn{ii});
  delta=abs(diff(clims(ii,:))/10000);
  cdata(find(cdata<=clims(ii,1)))=clims(ii,1)+delta;
  cdata(find(cdata>=clims(ii,2)))=clims(ii,2)-delta;
  set(hn(ii),srcn{ii},cdata);
  % Adjust the limits of the color axis:
  climsnew(1)=clims(ii,1)-diff(clims(ii,:))*(lencmap_old/lencmap_new);
  climsnew(2)=clims(ii,2);
%  caxis(get(hn(ii),'parent'),climsnew(ii,:));
%  set(axes_new(ii),'position',ax_newpos(ii,:));
  set(axes_new(ii),'clim',climsnew,'UserData',{'clim' clims(ii,:)})
end
% Now make the new colorbars:
if cbarflag
  [cbrs ind junk]=unique(cbars_new(:));
  axn=axes_new(ind);
  for i0=1:length(cbrs)
    chld=findobj(cbrs(i0),'type','image');
    if size(get(chld,'Cdata'),1)==1
      set(chld,'CData',lencmap_old+[1:lencmap_new])
    else
      set(chld,'CData',lencmap_old+[1:lencmap_new]')
    end
  end
end

done_ax=[];
% Old map loop:
for ii=1:length(ho)
  % Fix data to be plotted with the old colormap:
  clims=get(axes_old(ii),'clim');
  ud=get(axes_old(ii),'UserData');
  icl=find(strcmp(ud,'clim'))+1;
  if isempty(icl)
    set(axes_old(ii),'UserData',{'clim' clims})
    cdata=get(ho(ii),srco{ii});
    delta=abs(diff(clims)/10000);
    cdata(find(cdata<=clims(1)))=clims(1)+delta;
    cdata(find(cdata>=clims(2)))=clims(2)-delta;
    set(ho(ii),srco{ii},cdata);
  end
  if ~any(done_ax==axes_old(ii))
    climsnew(1)=clims(1);
    climsnew(2)=diff(clims)*(lencmap_all-lencmap_old)/lencmap_old+clims(2);
    % Adjust the limits of the color axis:
    set(axes_old(ii),'clim',climsnew);
    done_ax=[done_ax axes_old(ii)];
  end
  if exist('ocnt','var') && ocnt(ii)
    set(ho(ii),'linestyle',ls{ii})
  end
end
