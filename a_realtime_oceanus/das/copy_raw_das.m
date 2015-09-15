% copy das data from ark1

% want to copy the raw data from ark01 to my computer 


ddfromdates = dir([arkdir '20*']);

ddtodates = dir([localdir 'raw' filesep '20*']);

for ii = 1:length(ddfromdates)
    disp(['checking that ' ddfromdates(ii).name ' is up to date in ' [localdir 'raw' filesep]])
    warning off
    mkdir([localdir 'raw' filesep ddfromdates(ii).name])
    warning on
    copynewer([arkdir ddfromdates(ii).name filesep 'csv' filesep],...
        [localdir 'raw' filesep ddfromdates(ii).name],2,'csv')
end



