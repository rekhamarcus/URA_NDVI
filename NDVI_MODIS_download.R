library('dplyr')
library('sf')             
library('MODIStsp') #for downloading NDVI rasters
library('spData')
library("tidyr")
library('raster')

#import the shapefiles for the region to be observed
tweeds.spatial <- read_sf(dsn = 'Tweedsmuir/Tweeds_BGC_Zone/tepps_bec_zone.shp', layer = 'tepps_bec_zone') %>%
  st_transform(crs = '+proj=longlat')
bbox <- st_bbox(tweeds.spatial)

# download NDVI
MODIStsp(gui = FALSE, 
         out_folder = 'Data/NDVI', 
         selprod = 'Vegetation Indexes_16Days_250m (M*D13Q1)', #16 day data at 250m resolution
         prod_version = '061', 
         bandsel = 'NDVI', 
         sensor = 'Terra', 
         user = USERNAME, #input user's credentials in order to download
         password = PASSWORD, 
         start_date = '2000.01.01', 
         end_date = '2023.05.04', #set end date, or set today's date
         spatmeth = 'bbox',
         bbox = bbox, 
         out_projsel = 'User Defined', 
         output_proj = '+proj=longlat', 
         resampling = 'bilinear', 
         delete_hdf = TRUE, 
         scale_val = TRUE, 
         ts_format = 'R RasterStack', 
         out_format = 'GTiff', 
         n_retries = 10, 
         verbose = TRUE,
         parallel = TRUE) 


# plot raster to check 
if(FALSE) {
  library('tweeds.raster') # to import and save rasters
  load('Tweedsmuir/NDVI/tweeds.raster/tweeds.raster.rds')
  raster_ts %>%
    mask(tweeds.spatial) %>%
    crop(tweeds.spatial) %>%
    plot()
}

#create an object to save the rasters
rasters <-
  list.files(path = 'Data/NDVI/VI_16Days_250m_v61/NDVI/',
             pattern = '.tif', full.names = TRUE) %>%
  stack()

# save NDVI data as a dataframe - can skip this step and go directly to data wrangling
rasters %>%
  as.data.frame(xy = TRUE) %>%
  pivot_longer(-c(x, y)) %>%
  transmute(long = x,
            lat = y,
            date = substr(name, start = nchar('MOD13Q1_NDVI_x'), stop = nchar(name)) %>%
              as.Date(format = '%Y_%j'),
            ndvi = value) %>%
  saveRDS('Data/NDVI/tweeds.raster/tweeds.raster.rds')





