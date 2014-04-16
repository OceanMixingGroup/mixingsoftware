% Runs run_backup for HOME02 cruise
% see run_backup
fromdir = '\\Fishy\DATA\cvi\ChamDAQ\timix01\chameleons\raw\';
todir = '\\Ladoga\datad\cruises\tx01\chameleon\raw\';
prefix = 'tx01';
run_backup(fromdir,todir,prefix);
