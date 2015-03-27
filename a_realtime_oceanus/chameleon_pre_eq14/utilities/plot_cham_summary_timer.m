% plot_cham_summary_timer.m
%
% notes added by sjw, January 2014
%
% This code is called by show_chameleon_timer. It's added simply because
% sometimes errors occur in plot_cham_summary and putting them in a
% try/catch block prevents the code from crashing in an unfortunate way.

try
    % clear the variable cham and reload the latest version of the summary
    % file, writing the name of the file to the screen.
    clear cham
    load([path_b file_b]);
    disp(cham.filemax);
    
    % plot the newest version of the processed data.
    plot_cham_summary;
    fclose('all');
catch
    pause(1);
    clear cham
    load([path_b file_b]);
    disp(cham.filemax);
    plot_cham_summary;
end
