  function segments = findsegments(ibad)
%
% function segments = findsegments(ibad)
%
% ibad is index of bad data 
% returns indices:
%    segments.start
%    segments.stop
%    and
%    segments.length
% nx = length(data)
%
  
% test
%
testing = 0;
if testing
  x = rand(1, 20);
  x([1 4 6 7 8 15 16 17 18 20]) = -99; 
  ibad = find(x == -99);
end

ibad = ibad(:);

jj = find(diff(ibad) > 1);
nseg = length(jj) + 1;

istart = jj + 1;
istart = [1; istart];

istop = jj;
istop = [istop; length(ibad)];

segments.start = ibad(istart);
segments.stop = ibad(istop);
segments.length = segments.stop - segments.start + 1;
