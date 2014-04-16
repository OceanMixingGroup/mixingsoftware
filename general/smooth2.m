function outy = smooth(inny,hlength,vlength);
%
% outy = smooth(inny,hlength,vlength);
%
% boxcar filter along first and then second
% dimention of inny
% i.e. if inny=inny(a,b), than outy 
% would be filtered along a and then b
% hlength is a length of boxcar filter along b
% vlength is a length of boxcar filter along a
% 
 
  
  Lh=hlength;Lv=vlength;
% filter once horizontally 
bh = ones(Lh,1)/Lh;a=1;
bv = ones(Lv,1)/Lv;a=1;
  
  outy = gappy_filter(bv,a,inny,10,1,0);   
  outy = gappy_filter(bh,a,outy',10,1,0)';  
