function [coef,out]=get_T_calibration(ref_time,ref_T,raw_time,raw_T)

	
	raw_T_star=interp1(raw_time,raw_T,ref_time);
		
	b=regress(ref_T,[ones(size(raw_T_star)) raw_T_star raw_T_star.^2 raw_T_star.^3]);

	out=b(1)+raw_T*b(2)+raw_T.^2*b(3)+raw_T.^3*b(4);
	coef=[b' 1];
	
%	plot(ref_time,ref_T,raw_time,out);
	