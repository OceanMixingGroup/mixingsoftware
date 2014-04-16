function along = xytoalong(sta_x,sta_y,x,y);
% convery x,y into along-station distances....
% 
 
sta = sta_x+sqrt(-1)*sta_y;
X = x+sqrt(-1)*y;

dist(1) = 0;
for i=1:length(sta)-1
  st = sta(i+1)-sta(i);
  x = X-sta(i);
  along(i,:)=real(x.*conj(st)./abs(st));
  dist(i+1) = dist(i)+abs(st);
  
end;
dist = dist(1:end-1);

% now we want to figrue which of these is the right one.  The smallest
% non negative, if it exists, followed by the smallest negative...

for i=1:size(along,2);
  in = find(along(:,i)>=0);
  if isempty(in)
    [a(i),ind] = min(abs(along(:,i)));
    a(i)=a(i) + dist(ind);
  else
    [a(i),ind] = min(along(in,i));
    a(i) = a(i)+dist(in(ind));
  end;
end;

along = a;
