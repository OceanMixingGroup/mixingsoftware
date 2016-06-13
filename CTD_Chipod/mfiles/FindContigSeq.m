function b=FindContigSeq(idg)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%function b=FindContigSeq(idg)
%
% Given a vector of indices "idg" (in order) with gaps, find contiguous sections
%
% example: idg=[1 3 4 5 9 10]; there are 3 sections: [1], [3 4 5], [9 10]
%
% Returns structure b with fields:
%
% first: indice of 1st element of each section
% last: indice of last element of each section
% reglen: length of each section
% N, the total # regions.
% idg - the original vector passed in
%
% Partly based on response at http://stackoverflow.com/questions/2212201/matlab-fxn-find-contiguous-regions-and-return-bounds-in-struct-array
%
% AP 23 Jan 2012
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

%idg=[1 3 4 5 9 10]

A=zeros(1,max(idg));
A(idg)=1;
seq=find(diffs(idg(:))==1);
A(idg(seq))=1;
A(idg(seq)+1)=1;
D = diffs([0,A,0]');
b.first = find(D == 1);
b.last = find(D == -1) - 1;
b.N=size(b.first,1);
b.reglen=(b.last-b.first )+1; % t
b.idg=idg;
%disp(['There are ' num2str(N) ' separate regions '])

return
