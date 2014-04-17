mixingsoftware
==============

MATLAB software used by the Ocean Mixing Group at Oregon State University

<<<<<<< HEAD
mixingsoftware contains all of the MATLAB code to process and plot data collected by the Ocean Mixing Group. You are welcome to use the code if you find it useful via zip download.
=======
mixingsoftware contains all of the m-files that we use to process and plot data collected by chipods, ppods, chameleon, etc.
>>>>>>> FETCH_HEAD

This software is used by scientists in the group who hopefully update code when they find bugs … OMG, it happens! It is necessary for these changes to be distributed among the group so everyone is using the latest versions of the code. For now, outside users will not have the ability to update code - we would like them to but not sure at present how to   do the necessary quality control before accepting code updates. 

<<<<<<< HEAD
New code (for graphics, for example) can be submitted to a group member who can add it to the library. Add your name/date/contact_info to the script.  

You can download a .zip file of mixingsoftware by going to github.com and searching for mixingsoftware. The link to download is on the lower right of the screen.
=======
***********************************
>>>>>>> FETCH_HEAD

INSTALLATION FOR A "READER"

>>> This is for a user who never plans to update the code. Someone who will just add the files to their MATLAB path.

1. Download mixingsoftware by going to github.com and searching for "mixingsoftware". You do not need to create an account. The link to DOWNLOAD ZIP is on the lower right hand side of the screen. Click this button, save the .zip file, expand it, and put the mixingsoftware folder in a convenient, safe place on your computer (i.e. not the Downloads folder, but someplace where you store MATLAB files.)

2. In MATLAB, click on "Set Path". In the Set Path dialogue box, click on "Add with Subfolders". Navigate to the mixingsoftware folder and click "open" to add all of the folders within mixingsoftware to your MATLAB path. You may want to add these folders to the bottom of your path list.
   >>> Important note: when adding mixingsoftware to your MATLAB path, make sure that the folders are in alphabetical order (caps before lower case) within the path. There are cases of duplicate files and you want to make sure that MATLAB is using the correct one. For instance, mixingsoftware/marlcham/calc_salt.m is much newer than mixingsoftware/realtime/chameleon/calc_salt.m. Therefore, the subfolder "marlcham" must come before the subfolder "realtime". It is unfortunate that there are duplicates, but they have yet to be fixed because there is a fear of deleting something important. Duplications only becomes an issue if you add folders individually to your MATLAB path rather than using "Add with Subfolders." To check which version of a code MATLAB is using, type "which calc_salt" to make sure that it is the one in the "marlin" folder.



***********************************

INSTALLATION FOR AN "EDITOR"

>>> This is for a user who will use mixingsoftware often and will update the code and share their updates with the rest of the group. 

1. Go to github.com and create a username and password. Choose the free version of the software.

2. Install GitHub on your computer by downloading the application and moving it into your Applications folder (on a Mac). With a PC, just follow the installation instructions on github.com.

3. Inform an owner of the group what your username is so they can invite you to the OceanMixingGroup organization on github. You will receive an email when they have added you.

4. Once you are a member of OceanMixingGroup, go to your "Dashboard" by clicking on the github icon (cat) in the upper left hand corner of the screen. Just below that you should see a box with your username, click there and switch to OceanMixingGroup. (If you only see options to "Manage Organization" and "Create Organization", you have not been added to the OceanMixingGroup.) Now you can see all the updates that have happened to mixingsoftware. 

5. On the right, click on "OceanMixingGroup/mixingsoftware" which should bring you to a screen that shows you all of the software within mixingsoftware. Click on "Clone in Desktop" on right hand side of screen. Choose the folder where you would like to download the repository and save the repository to that location.

6. Now that you have mixingsoftware on your computer. Add it to your MATLAB path as described in step 2 above in "INSTALLATION FOR A READER".



UPDATING THE mixingsoftware REPOSITORY


nth. If you make a change to one of the codes in mixingsoftware
