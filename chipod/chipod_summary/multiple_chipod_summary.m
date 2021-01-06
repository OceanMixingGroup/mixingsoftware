%performs chipod summary files for multiple chipods especially on a mooring
rootname = 'C:\work\chipod\';
summary_loc = 'C:\work\chipod\';
lm = dir(rootname);

parfor j = 4:length(lm)
    display(lm(j).name);
    make_avg_chipod(str2num(lm(j).name),rootname,summary_loc);
end
