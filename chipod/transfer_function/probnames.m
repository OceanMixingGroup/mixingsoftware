% probnames.m
% probe names for compute_transfer_functions_filter.m
% define probe names and minimum and maximum filename index
% if no probe was used or data was bad set 999 for probe name
% deployment - deployment name
%   $Revision: 1.2 $  $Date: 2009/06/09 22:22:36 $
deployment='YQ08a';
% for sensors 0602 & 0601 see yq07a
% ch.t2=[603 604 606 608 610 527 529 530 504 508];%probe number
% ch.t3=[602 601 605 607 609 526 528 999 501 507];%probe number
ch.t1={'0526' '0529' '0606' '0623' '0807' '0810' '0814' '0817' '0823' '0826' '0829' '0832' '0835' '0838' '0840' '0843' '0846' '0849'};%probe number
ch.t2={'0528' '0604' '0611' '0627' '0808' '0811' '0815' '0818' '0824' '0827' '0830' '0833' '0836' '0839' '0841' '0844' '0847' '0850'};%probe number
ch.t3={'0603P' '0604P' '0606P' '0607P' '0611P' '0801P' '0802P' '0803P' '0805P' '0806P' '0807P' '0808P' '0808P' '0808P' '0808P' '0808P' '0808P' '0808P'};%probe number
ch.t4={'0530' '0605' '0612' '0628' '0809' '0813' '0816' '0819' '0825' '0828' '0831' '0834' '0000' '0837' '0842' '0845' '0848' '0851'};%probe number
filemins=[29 38 48 59 130 160 183 209 234 246 257 264 273 283 293 303 311 321]; %minimum filename index
filemaxs=[37 47 58 69 152 182 207 218 245 256 263 272 282 292 302 310 320 333];%maximum filename index
