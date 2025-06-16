library(tidyverse)

# ---- load: ridot bike paths
bike_paths <- read.csv("data/rigis/TRANS_Bike_Paths_RIDOT_spf_-3766862057690091566.csv")
# bike_paths %>% group_by(TYPE) %>% summarise(n = n()) %>% arrange(desc(n)) %>% View()
# bike_paths %>% group_by(STATUS) %>% summarise(n = n()) %>% arrange(desc(n)) %>% View()

# ---- load: bikeways and trails
# note: sf of bikes & trails (no other info)
bikes_n_trails <- read.csv("data/rigis/Bikeways_and_Trails_-4313519531934205638.csv")

# ---- load: land use 2025 map
land_use <- read.csv("data/rigis/PLAN_Land_Use_2025_spf_8673009129398931300.csv")
# land_use %>% group_by(Land.Use.Type) %>% summarise(n = n()) %>% arrange(desc(n)) %>% View()

# ---- load: neighborhood stabilization areas
# nice: lines up to census tract
nsp <- read.csv("data/rigis/PLAN_Neighborhood_Stabilization_Program_Target_Areas_spf_806693686263095835.csv")

# ---- load: scorp inventory of facilities
# probably won't be that helpful
facilities <- read.csv("data/rigis/SCORP_Inventory_2024_-3508053959364545401.csv")
