% top level routine for processing files and making the summary
% file.  

initialize_summary_file;
load nextfile;
while 1
    wait=1;
    load_file=[q.script.pathname q.script.prefix sprintf('%04.3f',nextfile/1000)]
    next_file=[q.script.pathname q.script.prefix sprintf('%04.3f',(nextfile+1)/1000)];
    if exist(next_file,'file')
        disp(['processing file ' load_file]) 
        q.script.num=nextfile;
        nextfile=nextfile+1;
        save nextfile nextfile
        process_file
    end
    if wait; for i=1:4; pause(5); end; end
end
