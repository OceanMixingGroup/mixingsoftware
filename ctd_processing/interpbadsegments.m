  function y = interpbadsegments(x, ibad)
% function y = interpbadsegments(x, ibad)

segs = findsegments(ibad);
nsegs = length(segs.start);
y = x;
for ii = 1:nsegs
  if ~mod(nsegs, 1000)
    disp(['interpbadsegments: ' num2str(nsegs - ii)])
  end
  i1 = segs.start(ii) - 1;
  i2 = [segs.start(ii):segs.stop(ii)]';
  i3 = segs.stop(ii) + 1;
  if i1 < 1 
    disp('interpbadsegments: bad at istart - no interpolation at start')
  elseif i3 > length(x)
    disp('interpbadsegments: bad at istop - no interpolation at stop')
  else
    y(i2) = interp1q([i1 i3]', x([i1 i3]), i2);   
  end
end