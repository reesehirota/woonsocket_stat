library(tidyverse)
library(sf)
library(leaflet)
library(htmltools)

# ---- load: ridot bike paths
bike_paths <- read_sf("data/rigis/TRANS_Bike_Paths_RIDOT_spf_6654327448778679796.geojson") %>% 
  st_transform(4326) # re-project for mapping
# bike_paths %>% group_by(TYPE) %>% summarise(n = n()) %>% arrange(desc(n)) %>% View()
# bike_paths %>% group_by(STATUS) %>% summarise(n = n()) %>% arrange(desc(n)) %>% View()

# ---- load: bikeways and trails
# note: sf of bikes & trails (no other info)
bikes_n_trails <- read_sf("data/rigis/Bikeways_and_Trails_-6810032319405835885.geojson") %>%
  st_transform(4326)

# ---- load: land use 2025 map
land_use <- read.csv("data/rigis/PLAN_Land_Use_2025_spf_8673009129398931300.csv")
# land_use %>% group_by(Land.Use.Type) %>% summarise(n = n()) %>% arrange(desc(n)) %>% View()

# ---- load: neighborhood stabilization areas
# nice: lines up to census tract
nsp <- read.csv("data/rigis/PLAN_Neighborhood_Stabilization_Program_Target_Areas_spf_806693686263095835.csv")

# ---- load: scorp inventory of facilities
# probably won't be that helpful
facilities <- read.csv("data/rigis/SCORP_Inventory_2024_-3508053959364545401.csv")

# ---- map: bikeways and trails
leaflet() %>%
  addProviderTiles(provider = "CartoDB.Positron") %>%
  addPolylines(data = bikes_n_trails, color = "#00bf7d",
               group = "Bikeways and trails per the RI state greenways plan",
               opacity = 1, 
               weight = 5) %>%
  addPolylines(data = bike_paths, color = "#5928ed",
               group = "RIDOT bike paths",
               label = str_to_title(bike_paths$PROJ_NAME),
               opacity = 1,
               weight = 5) %>%
  addLayersControl(position = "bottomright",
                   overlayGroups = c("Bikeways and trails per the RI State Greenways Plan",
                                  "RIDOT bike paths"),
                   options = layersControlOptions(collapsed = FALSE))
