README for MatLab PWP:

This package is an implemementation of the Price-Weller-Pinkel (PWP) upper ocean model described in JGR 91, C7 8411-8427. A copy of the paper can be found here:

http://www.whoi.edu/science/PO/people/jprice/

A number of modifications have been made to allow use of observed forcing fields and initialization using a CTD cast, but the routine has not been extensively tested, nor does it identically reproduce results of existing and widely used existing versions of the model (e.g. WHOI-UOP group's c-version).  However, in comparisons with the c-version, differences are very small (and probably related to numerical effects; e.g., 1 grid cell difference in mixed layer depth).


Requisites:
You need the SeaWater routines installed, to calculate the density and the Coriolis parameter. They can be found here:

http://woodshole.er.usgs.gov/operations/sea-mat/


Code History/Credits:

- Original Matlab code is presumably by David Glover (for his 12.747 class at MIT). It was modified quite a bit for this release.
- the mmv2struct was written by D.C. Hanselman, University of Maine.

