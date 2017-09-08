function status_out = check_data_struct_ctd_chipod(the_project,mixpath)
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%
% run before processing ctd_chipod cruise, to check that data is all there
% and in correct directory structure for processing
%
% also check that mixpath exists?
%
% INPUT
% - the_project
% - mixpath
%
%
%------------
% 09/07/17 - A.Pickering - andypicke@gmail.com
%~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
%%

has_errors = 0 ;


%~~~~~~~~~~~~~~~~~~~~~~
% does mixpath exist?
%~~~~~~~~~~~~~~~~~~~~~~


if exist(mixpath)==7
    %disp('mixpath exists')
else
    has_errors = 1 ;
    disp('mixpath does not exist')
end


%~~~~~~~~~~~~~~~~~~~~~~
% do we have required folders in mixpath?
%~~~~~~~~~~~~~~~~~~~~~~


if exist(fullfile(mixpath,'CTD_Chipod'))==7
    %disp('mixpath/CTD_chipod exists')
else
    has_errors = 1 ;
    disp('mixpath/CTD_chipod does not exist')
end


if exist(fullfile(mixpath,'CTD_Chipod','mfiles'))==7
    %disp('mixpath/CTD_chipod/mfiles exists')
else
    has_errors = 1 ;
    disp('mixpath/CTD_chipod/mfiles does not exist')
end

if exist(fullfile(mixpath,'chipod'))==7
    %disp('mixpath/chipod exists')
else
    has_errors = 1 ;
    disp('mixpath/chipod does not exist')
end

if exist(fullfile(mixpath,'general'))==7
    %disp('mixpath/general exists')
else
    has_errors = 1 ;
    disp('mixpath/general does not exist')
end


if exist(fullfile(mixpath,'marlcham'))==7
    %disp('mixpath/marlcham exists')
else
    has_errors = 1 ;
    disp('mixpath/marlcham does not exist')
end


if exist(fullfile(mixpath,'adcp'))==7
    %disp('mixpath/adcp exists')
else
    has_errors = 1 ;
    disp('mixpath/adcp does not exist')
end



%~~~~~~~~~~~~~~~~~~~~~~
% check data structure
%~~~~~~~~~~~~~~~~~~~~~~



if has_errors==0
    disp('looks good!')
    status_out = 1 ;
else
    status_out=0;
end

%%
%%