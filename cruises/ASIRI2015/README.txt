
ASIRI2015

This folder contains m-files from August 2015 ASIRI cruise on R/V Revelle (RR1513). Starting point will be m-files from scienceparty_share that was used on cruise. Data will eventually be hosted on servers somewhere tbd.

Going forward all paths in m-files should be made general to work for different users and data locations with minor adjustments. 

All paths in scripts will be relative to 2 main paths:

(1) ‘SciencePath’ , which is the path to the scienceparty_share archive (for data)

(2) ‘MfilePath’ , which is path to your copy of the m-file github repository

You should be able to set these in your version of SetPathsAsiri_AP.m , and just execute that script before you start any pocessing.