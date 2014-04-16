function out=remove_sonar_spikes(in,thres);
  
% Function out=remove_sonar_spikes(in,OPT_THRESHOLD) removes the 2.5 second spikes
% introduced by the sonar.  The threshold default is 0.07.
  if nargin==1
	thres=.07;
  end
  out=in;
  deriv=diff(in,2);
  inds=find(deriv>thres)+1;
  inds(find(inds<6))=6;
  inds(find(inds>(length(in)-6)))=length(in)-6;
  if length(inds)>250*length(in)
	warning(['Remove_sonar_spikes removed 1 in ' ...
			 num2str(floor(length(in)/length(inds))) ' points'])
	end
  for i=-4:4
	out(inds+i)=mean([in(inds+5) in(inds-5)],2);
  end
