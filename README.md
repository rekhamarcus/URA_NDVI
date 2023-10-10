# NDVI
This is the repository for my Undergraduate Research Award Project using NDVI to quantify 
habitat quality across Caanada. This repository will include R scripts for all stages of the project, 
from downloading the data to wrangling and modelling. 

Look at the Scripts folder for updated R scripts on all the different stages of the project. 

The file `NDVI_MODIS_download.R` includes the code on how to download NDVI data from NASA's MODIS
satellite. This requires an account via earthdata.org.

The file `NDVI_data_wrangling.R` includes the code for converting the downloaded NDVI files to
a data frame with data that could then be fed into a GAM. In this script, the NDVI data was combined with
spatial information of regions that had been clear cut (referred to as cutblocks). This was a topic of
interest to some of our research partners who wanted to know how clear cutting affected productivity and 
forest regeneration. The workflow (including data wrangling and modelling) for cutblocks is an example of what can be done with this project.

The file `NDVI_gam_model.R` contains the code for the final `gam` that was run using the `mgcv` package
written by Simon Wood, who kindly wrote a beta location scale function for us to use on this project
(identified by `family = betals()` in the code). This code was also used to generate predictions for this
data, and plot the final outcomes. 
