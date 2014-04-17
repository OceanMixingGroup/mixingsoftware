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
<<<<<<< HEAD
New code (for graphics, for example) can be submitted to a group member who can add it to the library. Add your name/date/contact_info to the script.  

You can download a .zip file of mixingsoftware by going to github.com and searching for mixingsoftware. The link to download is on the lower right of the screen.
=======
=======
These notes written by Sally Warner, April 2014

>>>>>>> FETCH_HEAD
***********************************
>>>>>>> FETCH_HEAD

INSTALLATION FOR A "READER"

>>> This is for a user who never plans to update the code or receive updates from other users. Someone who will just download the files and add them to their MATLAB path.

1. First, rename your old version of mixingsoftware to something like "mixingsoftware_old_April2014.” Download mixingsoftware by going to https://github.com/OceanMixingGroup/mixingsoftware/. You do not need to create an account. Click on the button “Download Zip” on the lower right hand side of the screen. Save the .zip file, expand it, and put the mixingsoftware folder in a convenient, safe place on your computer.

2. In MATLAB, click on "Set Path.” Remove paths to the previous version of mixingsoftware. In the Set Path dialogue box, click on "Add with Subfolders.” Navigate to the mixingsoftware folder and click "open" to add all of the folders within mixingsoftware to your MATLAB path. You may want to add these folders to the bottom of your path list.
   >>> Important note: when adding mixingsoftware to your MATLAB path, make sure that the folders are in alphabetical order (caps before lower case) within the path list. There are cases of duplicate files and you want to make sure that MATLAB is using the correct one. For instance, mixingsoftware/marlcham/calc_salt.m is much newer than mixingsoftware/realtime/chameleon/calc_salt.m. Therefore, the subfolder "marlcham" must come before the subfolder "realtime.” It is unfortunate that there are duplicates, but they have yet to be fixed because there is a fear of deleting something important. Duplications only becomes an issue if you add folders individually to your MATLAB path rather than using "Add with Subfolders." To check which version of a code MATLAB is using, type "which calc_salt" to make sure that it is the one in the "marlin" folder.



***********************************

INSTALLATION FOR AN "EDITOR"

>>> This is for a user who will use mixingsoftware often. By installing this way, you will be able to update the master repository when you make changes to the code and you will receive updates made by others.

1. Go to github.com and create a username and password. Click “Sign up for GitHub.” Choose the free version of the software. Click on “Finish Sign Up.”

2. Contact an owner of the OceanMixingGroup organization (such as Jim, Sally or Pavan). They need to add you to the organization before you can proceed. You will receive an email once they have added you.

3. Once you are a member of OceanMixingGroup, go to your "Dashboard" by clicking on the github icon (cat) in the upper left hand corner of the screen. Just below that you should see a box with your username, click there and switch to OceanMixingGroup. (If you only see options to "Manage Organization" and "Create Organization,” you have either not been added to the OceanMixingGroup organization or you need to reload the page.) Under “Repositories,” click on “OceanMixingGroup/mixingsoftware.” From here, you can see all of the software.

4. On the lower right-hand side of the page, click on “Clone to Desktop” button. Provided GitHub is not already installed on your computer, this should take you to the GitHug download page.

5. Download, unzip and install the GitHub application on your computer. (On a mac, this is as easy as moving the GitHub icon from the Downloads folder to the Applications folder.) Open the GitHub application. Set up the application with your github.com username, email and password. (If you get a message about password keychains, click “Allow” or “Always Allow.”) You do not need to install the command line tools unless you prefer the command line to the gui interface.

6. Now, you need to clone the mixing software repository to your computer. First, rename your old mixing software to something like “mixingsoftware_old_April2014.” Then in GitHub, click on OceanMixingGroup on the left hand side of the window. Then click on “Clone to Computer” next to OceanMixingGroup/mixingsoftware. Choose the location where you would like to save the repository. Click “Clone” and the repository is saved to your computer.

7. Now that you have mixingsoftware on your computer. Add it to your MATLAB path as described in step 2 above in "INSTALLATION FOR A READER".

8. You should be good to go.


UPDATING THE MIXINGSOFTWARE REPOSITORY

If you make changes to mixingsoftware you will need to update the master repository (on github.com/OceanMixingGroup/mixingsoftware), and if someone else makes a change to mixingsoftware, you will want to receive their update. Both of these are controlled through the GitHub application on your computer.

1. In GitHub, click on the right-pointing arrow next to OceanMixingGroup/mixingsoftware to see the changes that you or others have made.

2. If you have made a change to mixingsoftware, the “Changes” button will appear with a red and green “+/-.” To push these changes to the repository, write a summary of your changes, then click on “Commit & Sync.” (If you only see a “Commit” button, click on the “+” with circle arrows.) The master repository should now be updated.

3. To update your local branch of the repository, click on “Sync Branch” in the upper-right corner. This automatically updates your version of mixingsoftware to match the master repository on github.com. 
     > Your settings within github.com (Notification center) determine whether you will receive emails when the repository has been updated. You can turn these notifications on and off.
