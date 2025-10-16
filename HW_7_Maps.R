## Setup: loading packages
library(tidyverse)
library(terra)

## reading in .csv files with the site latitude and longitudes
germination.sites <- read.csv("GR_GermSites.csv")
dispersal.sites <- read.csv("Transect_Locations_Clean.csv")

## dispersal.sites contains locations at multiple points along a 
## transect. I'm going to filter the df to include only one point 
## per transect
dispersal.sites <- 
  dispersal.sites %>% 
  filter(Location == 25 | Location == 0) %>%
  select(Transect, X, Y) ## also only selecting the columns I need

## making a column for the site type so that I can eventually plot them separately
dispersal.sites$SiteType <- c(rep("Seed Pressure Transect", 6), rep("Dispersal Transect", 12))

## separating into two data frames based on site type
seed.pressure.sites<- dispersal.sites %>% filter (SiteType == "Seed Pressure Transect")
dispersal.sites <- dispersal.sites %>% filter (SiteType != "Seed Pressure Transect")

## Organizing the germ site data frame to match the dispersal dfs
germination.sites <- germination.sites %>% 
  select(Plot.ID, X, Y) %>%
  rename("Transect" = "Plot.ID") %>%
  mutate(SiteType = c(rep("Germination", 12)))

## Before we can map the sites, I need to read in the fire perimeter
MC.fire <- vect("Shapefiles/2018.shp")

## Also need to make sure that both files are using the same coordinate 
## reference system
MC.fire <- project(MC.fire, "epsg:26912")

## vectorizing the df of site locations into points
disp.points <- vect(dispersal.sites, geom=c("X", "Y"), crs="epsg:26912", keepgeom=FALSE)
germ.points <- vect(germination.sites, geom=c("X", "Y"), crs="epsg:26912", keepgeom=FALSE)
seed.pressure.points <- vect(seed.pressure.sites, geom=c("X", "Y"), crs="epsg:26912", keepgeom=FALSE)

## plotting them all together! 
plot(MC.fire)
add_legend(x = 528000, y = 4735000, #Specifies where to put the legend
           legend = "Marten Creek Fire", 
           x.intersp = -0.5) #Specifies how much space between the legend and its boc
plot(disp.points, 
     col = "red", 
     pch = 20,
     add = T) ## adding the dispersal transects in red
plot(germ.points, 
     col = "green", 
     pch = 20,
     add = T) ## adding the germination plots in green 
plot(seed.pressure.points, 
     col = "black", 
     pch = 20,
     add = T) ## adding the seed pressure transects in black
add_legend(x = 531000, y = 4729000,
           legend = c("Dispersal Transect", "Germination Plot", "Seed Pressure Transect"), 
       pch = 20, xpd=NA, bg="white", col=c ("red", "green", "black")) ## adding a legend

