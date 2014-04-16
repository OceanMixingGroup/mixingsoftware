function outy = smooth(inny,length);
% boxcar filter along first dimention of inny
% i.e. if inny=inny(a,b) than
% outy would be filtered along a
% length is a length of boxcar filter
% 
  
  Lh=length;
% filter once horizontally 
bh = ones(Lh,1)/Lh;a=1;
  
outy = gappy_filter(bh,a,inny,10,1,0);  
