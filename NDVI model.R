library('mgcv')
library('raster')
library('dplyr')

#import data
ndvi<- readRDS('Data/NDVI/tweeds.raster/tweeds.raster.rds')

#place data into a table
ndvi.data <- babyndvi %>%
  group_by(long, lat) %>%
  summarise(
    mean = mean(ndvi)
    sd = sd (ndvi)
    var = var(ndvi)
    cv = var/sd
    Count = n())

#visualize data
scatter <- plot(babyndvi$date, babyndvi$ndvi)

#run gam for a single global smoother using cubic regression splines
tweeds.ndvi <- gam(ndvi.data$cv ~ s(ndvi.data$cv, k=10, bs="cs"), 
                   data=babyndvi, method="REML", family="gaussian")

