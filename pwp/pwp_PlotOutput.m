%pwp_PlotOutput Plot Output during PWP Run

% Plot:
if plotflag~=1	            % If plotting is enabled
	return
end

if it==tstart
	subplot(5,2,5:6), 
	plot(time,FWFlux); hold on
	ylabel('Fresh Water');
	set(gca,'xtick',[]);
	subplot(5,2,7:8), plot(time,abs(complex(taux,tauy)));
	hold on
	ylabel('Wind Stress Magnitude')
	set(gca,'xtick',[]);
	subplot(5,2,9:10), 
	plot(time,thf,time,rhf);
	hold on
	ylabel('THF/RHF');
end
if rem(it,tintv)==0
	timenow=time(it)*ones(1,2);
	delete(findobj('tag','refline'));
	% Plot Reference Lines
	subplot(5,2,5:6), 
	plot(timenow,ylim,'k','tag','refline');
	subplot(5,2,7:8), 
	plot(timenow,ylim,'k','tag','refline');
	subplot(5,2,9:10), 
	plot(timenow,ylim,'k','tag','refline');
	gregaxd(xlim,1);

	% Plot temperature profile
	subplot(5,2,[1 3]),
	plot(T,z,T_0,z,'g')
	grid on              
	set(gca, 'YDir', 'reverse')
	ylabel('depth (m)')
	xlabel('temp (deg C)')
	axis([10 30 0 zmax])
	title(['Time: ' num2str(it)]);
	
	% Plot Velocity
	subplot(5,2,[2 4]),
	plot(UV(:,1), z, UV(:,2),z,'g')
	grid on
	set(gca, 'YDir', 'reverse')
	ylabel('depth (m)')
	xlabel('vel (m/s)')
	title('U=blue, V=green');
	axis([-.5 .5 0 zmax])
end

% Make sure plot is 'On The Fly'
drawnow
