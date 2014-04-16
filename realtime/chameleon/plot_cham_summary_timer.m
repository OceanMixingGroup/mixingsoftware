% plot_cham_summary_timer.m
try
    clear cham
    load([path_b file_b]);
    disp(cham.filemax);
    plot_cham_summary;
    fclose('all');
catch
    pause(1);
    clear cham
    load([path_b file_b]);
    disp(cham.filemax);
    plot_cham_summary;
end
