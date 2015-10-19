function vel=getvel5(dat,offset,nbins);

offset = offset+2;

vel = dat(offset+2*[1:nbins]-1)+256*(dat(offset+2*[1:nbins]));
vel(vel>=32768)=-2*32768+vel(vel>=32768);