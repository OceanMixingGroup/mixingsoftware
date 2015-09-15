% copy_das_oceanus.m
%
% For some reason, it is ridiculously slow to read the das data from TFour.
% Maybe copying everything locally first will help
%
% nevermind... use Ark1, it's significantly faster. Also, maybe easier to
% just copy manually becuase i don't think this is working all that well.

clear all

%%

% directory on ark1
fromdir = '/Volumes/cruise/current/das/';

% local directory
todir = '~/GDrive/data/eq14/das/raw/';

% list if files in fromdir
tic
ddfromdates = dir([fromdir '2*']);
toc
for ii = 1:length(ddfromdates)
    fromdates(ii,:) = char(ddfromdates(ii).name);
    disp(['day num: ' num2str(ii) ', foldername: ' fromdates(ii,:)])
end

days = input('Which days do you want to copy? (egs. 1 or 4:6): ');

% copy files
tic
for ii = days
    disp(num2str(ii))
    copyfile([fromdir ddfromdates(ii).name filesep 'csv' filesep '*.csv'],...
        [todir ddfromdates(ii).name filesep 'csv' filesep])
end
toc