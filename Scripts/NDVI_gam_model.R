library('tidyr')
library('dplyr')  
library('ggplot2')   #for plots
library('mgcv')    # for GAMs

source('Functions/betals.r') #beta location scale function for gam - written by Simon Wood
source('Functions/ndvi_pal_lim.r') #ndvi color palette for maps

#import the data
d <- readRDS('Tweedsmuir/Data/data.final.rds')

#subset data to run on a smaller subset and test model
#babyd <- slice(d, seq(from = 1, to = 1474925614, by = 1000))

#run model--------------------------------------------------------------------------------

model_ndvi <-
   gam(list(
      # mean predictor
         NDVI ~ 
            s(long, lat, k = 100) + #observe trends geographically
            s(year, bs = 'cr', k = 7) + #view trends over time
            s(doy, bs = 'cc', k = 8) + #view yearly trends
            ti(year, doy, bs = 'cc') + #view how yearly trends changed over time
        # variance predictor
          ~ 
            s(long, lat, bs = 'ds', k = 50) +
            s(year, bs = 'cr', k = 5) +
            s(doy, bs = 'cc', k = 5)+
            ti(year, doy, bs = 'cc')),
        family = betals(), #beta location scale distribution for the data
        data = d,
        method = 'REML',
        knots = list(doy = c(0.5, 366.5)),
        control = gam.control(nthreads = 30), trace = TRUE)

#check model outputs
summary(model_ndvi)
gam.check(model_ndvi)
plot(model_ndvi, pages = 2, scheme = 3, scale = 0, n = 250) + # plot smooths
  + layout(matrix(1:2, ncol = 2))

saveRDS(model_ndvi, "Tweedsmuir/tweeds.betals.july17.rds")

#generate predictions -----------------------------------------------------------------------

#create objects to hold the unique dates and the results
DAYS <- unique(d$dec_date)
RES <- list()

#create a loop to predict the new data from the model
for(i in 1:length(DAYS)){
newd <- filter(babyd, date == DAYS[i])

#add the predicted values back to the data frame with all the data
preds <-
  bind_cols(newd,
            as.data.frame(predict(model_ndvi, newdata = newd, type = 'response')) %>%
              rename(mu = V1,
                     phi = V2) %>%
              mutate(sigma2 = phi * (1 - mu) * mu,
                     mu = mu * 2 - 1,
                     sigma2 = sigma2 * 4))

RES[[i]] <- data.frame(day = unique(preds$date),
           mu = mean(preds$mu),
           var = mean(preds$sigma2))

}

RESULTS <- do.call(rbind, RES)

#plot the estimated mean and variance from the models onto a map
ggplot() +
  geom_raster(data = RESULTS, aes(long, lat, fill = mean)) +
  scale_fill_gradientn('ndvi', colours = ndvi_pal, limits = c(0, 1)) +
  theme_classic()

ggplot() +
  geom_raster(data = RESULTS, aes(long, lat, fill = var)) +
  scale_fill_gradientn('ndvi', colours = ndvi_pal, limits = c(0, 1)) +
  theme_classic()


