function vel=getint5(dat,offset,nbins);

offset = offset+2;

%vel = dat(offset+[1:4*nbins]);
vel = dat(offset+[1:nbins]);
%%