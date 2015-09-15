% copy_proc_das.m

ddfromdates = dir([localdir 'processed' filesep '20*']);
ddfrommat   = dir([localdir 'processed' filesep '*.mat']);

ddtodates = dir([wdmycloud 'processed' filesep '20*']);
ddtomat   = dir([wdmycloud 'processed' filesep '*.mat']);


for ii = 1:length(ddfromdates)
    disp(['checking that ' ddfromdates(ii).name ' is up to date in ' [wdmycloud 'processed' filesep]])
    warning off
    mkdir([wdmycloud 'processed' filesep ddfromdates(ii).name])
    warning on
    copynewer([localdir 'processed' filesep ddfromdates(ii).name filesep],...
        [wdmycloud 'processed' filesep ddfromdates(ii).name],2,'mat')
end


disp(['checking that mat-files are up to date in ' [wdmycloud 'processed' filesep]])
copynewer([localdir 'processed' filesep],[wdmycloud 'processed' filesep],2,'mat')



