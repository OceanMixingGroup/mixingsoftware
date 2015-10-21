
Processing scripts for pipe string ADCP on August 2015 ASIRI cruise. Starting point was files from previous ASIRI cruise (written by Jen MacKinnon?), which Emily Shroyer put here. A. Pickering starting to modify for Aug 2015 cruise on 08/25/15. 

*10/21/15 - A. Pickering - Copied pipe string m-files to github repository from my copy of scienceparty_share from 09/21/15.



To run entire processing, *RunPipestring.m*. Only new files that have not been processed are done (does not reprocess old files). This runs the following scripts:

1) loadsaveENR.m

Loads raw data from pipe string and reads into mat files.

2) asiri_read_running_nav.m

Reads raw navigation data from ship into mat files.

3) process_pipestring.m

Load raw adcp and navigation files. Combine all files into one structure. Transform to earth coordinates. Remove ship velocity. Average a bit. 

4) PlotPipestringSummary.m

Make summary figure.