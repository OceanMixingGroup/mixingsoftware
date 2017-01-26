function ChkMkDir(dirname)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
%
%-----------
% A.Pickering
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%disp(['Checking/making directory ' dirname])

if exist(dirname,'dir')==0
    disp(['Making new directory ' dirname])
    mkdir(dirname)
else
 %   disp('Directory already exists')
end

return