% load survey.mat and read the survey information.  It is plausible that
% this will change mid-deployment, so this is checked once a minute....

fname = [surveypath '\survey.mat'];
if ~exist(fname)
  warning(['Cannot open ',fname]);
  return;
end;
d=dir(fname);

time = datenum(d.date);
datestr(oldtime)
datestr(time)
time - oldtime
changesurvey=1
if changesurvey
  oldtime =time;
  load(fname);

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % lat-lon location plot....
  
  axes(plotinfo.posaxes);
  delete(get(gca,'child'));
  plotinfo.posmark=[];
  plot_bathy_c([bathypath '\' survey.bathyfile],survey.cvminor, ...
               survey.cvmajor);
  hold on;
  set(plotinfo.posaxes,'xlim',survey.lonlim,'ylim',survey.latlim);
  % plot the track
  if isfield(survey,'stations')
    for i=1:length(survey.stations.lon)
      hp(i)=plot(survey.stations.lon(i),survey.stations.lat(i),'dr');
      set(hp(i),'markeredgecolor','none');
      set(hp(i),'markerfacecolor','g');
    end;
  end;
  hold on;
  plot(survey.lon,survey.lat,'color',[0 0.8 1]*0.7,'linewidth',2);
  plot(survey.lon(1),survey.lat(1),'go','linewidth',2);
  plot(survey.lon(end),survey.lat(end),'rx','linewidth',2);
  
  % plot interesting points...
  if isfield(survey,'stations');
    hp=plot(survey.stations.lon,survey.stations.lat,'d');
    set(hp,'markeredgecolor','none');
    set(hp,'markerfacecolor',[0 0.7 0.0],'markersize',8);
  end;
  
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Along-Depth plot
  axes(plotinfo.depthaxes);
  set(gca,'fontsize',14,'xgrid','on','ygrid','on');
  delete(get(gca,'child'));
  hold off;
  if (isfield(track,'along') & isfield(track,'depth'));
    plot(track.along/1e3,track.depth,'.','colo',[0 0.8 0]);
  end;
  set(gca,'color',axesbackcol);
  hold on;
  for ik=1:length(survey.along);
    %ik
    %survey.along(ik)*[1 1]/1e3
    plot(survey.along(ik)*[1 1]/1e3,[0 5000],'m','linewidth',2);
  end;
  title(sprintf('surveyfile: ../surveydata/%s',survey.name))
  
  if 0
    % put the interesting places on as a line...
    if isfield(survey,'stations');
      [x,y]=j_ll2xy(survey.stations.lon,survey.stations.lat, ...
                    survey.cenlat);
      r=(x-survey.x(1) + ...
         sqrt(-1)*(y-survey.y(1))).*exp(-sqrt(-1).*survey.angle);
      alongx=real(r)/1e3;
      acrossx=imag(r)/1e3;
      hl=line([alongx; alongx],[0 10000]'*ones(1,length(alongx)));
      set(hl,'linewidth',2,'colo',[0 0.8 0]);
    end;
  end;
  
  plotinfo.marlindepthx=[];
  h=line([0 500],[0 0]);hold on;
  set(h,'color','k','linewidth',2);
  hold on;
  axis('ij')
  ylabel('DEPTH / m','fontang','ob');
  xlabel('ALONG TRACK / km','fontang','ob');
    changesurvey=0;

end



