library('dplyr')     # for data wrangling
library('ggplot2')   # for fancy plots
library('mgcv')      # for GAMs
library('lubridate')
library('ggplot2') # for fancy figures
library('stringi') # for working with strings

# custom NDVI color palette
create_ndvi_pal <- colorRampPalette(c('darkblue', 'dodgerblue', '#744700', '#d9bb94',
                                      'darkgreen'))
ndvi_pal <- create_ndvi_pal(100)

# object that stores NDVI data
ndvi <- readRDS('Data/NDVI/VI_16Days_250m_v61.rds')

#babyndvi <- slice(ndvi, seq(from = 1, to = 112509744, by = 1000))
#this function will extract a sample of the data in order to test the model before
# running the full model

#create 3 data groups
d <- mutate(ndvi,
            dec_date = decimal_date(date),
            year = year(date),
            doy = yday(date))

d %>%
  filter(year == unique(year)[1]) %>%
  ggplot(aes(long, lat, fill = ndvi)) +
  facet_wrap(~ doy) +
  geom_raster() +
  geom_sf(data = stshp, inherit.aes = FALSE, alpha = 0.3) +
  scale_fill_gradientn('NDVI', colours = ndvi_pal, limits = c(-1, 1))

#run the model
model_ndvi <-
  gam(list(
    # mean predictor
    ndvi ~
      s(long, lat, bs = 'ds', k = 100) + 
      s(year, bs = 'tp', k = 1) + 
      s(doy, bs = 'cc', k = 24),
    # precision (1/standard deviation) predictor
    ~
      s(long, lat, bs = 'ds', k = 80) +
      s(year, bs = 'tp', k = 1) +
      s(doy, bs = 'cc', k = 20)),
    family = gaulss(b = 0.0001), # using minimum standard deviation of 0.0001
    data = babyndvi,
    method = 'REML',
    knots = list(doy = c(0.5, 366.5)),
    control = gam.control(nthreads = 4), trace = TRUE)

#save model as rds file
saveRDS(model_ndvi, file = 'Analysis/tweeds-mgcv-ndvi-gaulss.rds')

#plot the model and run a gam.check to check the data and k values
if(FALSE) {
  plot(model_ndvi, pages = 1, scheme = 3, scale = 0, n = 250) # plot smooths
  layout(matrix(1:4, ncol = 2))
  gam.check(model_ndvi)
  layout(1)
}