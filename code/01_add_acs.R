library(tidyverse)
library(tidycensus)
library(sf)
library(leaflet)

# ==== DATA CLEANING ====
ri <- read_sf("data/rigis/BND_Municipalities_1997_spf_7961266610932060015.geojson") %>% 
  st_transform(4326) # re-project for mapping
woonsocket <- ri %>% filter(NAME == "WOONSOCKET") %>% 
  st_transform(4326)
p_county <- ri %>% filter(COUNTY == "PROVIDENCE") %>% 
  st_transform(4326)
not_woonsocket <- ri %>% filter(NAME != "WOONSOCKET") %>% 
  st_transform(4326)
rm(ri)

# explore variables
all_vars <- load_variables(2023, "acs5", cache = TRUE) %>% 
  filter(geography == "block group")
selected_vars <- all_vars %>%
        # variable : means of transportation to work
  filter((grepl("B08134", name) & !(grepl("minutes", label, ignore.case = TRUE))) |
           # variable : allocation of snap
           grepl("B22010", name) |
           # variable: race demographics - note that hispanic is considered an ethnicity
           grepl("B01001", name) & (label == "Estimate!!Total:")) %>% 
  pull(name) %>%
  unique() 
temp <- all_vars %>%
  # variable : means of transportation to work
  filter((grepl("B08134", name) & !(grepl("minutes", label, ignore.case = TRUE))) |
           # variable : allocation of snap
           grepl("B22010", name) |
           # variable: race demographics - note that hispanic is considered an ethnicity
           grepl("B01001", name) & (label == "Estimate!!Total:")) %>%
  rename("variable" = "name")
  
raw_acs = get_acs(geography = "block group", 
                   variables = selected_vars,
                   state = "RI",
                   geometry = TRUE,
                   year = 2023)
raw_acs <- raw_acs %>%
  st_transform(4326) # transform to match crs of rigis
# raw_acs <- raw_acs %>%
#   mutate(in_woonsocket = lengths(st_intersects(raw_acs, woonsocket))) %>%
#   mutate(in_pcounty = lengths(st_intersects(raw_acs, p_county))) %>%
#   mutate(not_woonsocket = lengths(st_intersects(raw_acs, not_woonsocket))) 
raw_acs <- raw_acs %>% left_join(temp, by = "variable")
rm(temp) ; rm(all_vars) ; rm(selected_vars)
# sex by age
# acs_sba <- raw_acs %>% filter(concept == "Sex by Age")

# means of transportation to work by travel time to work
acs_transport <- raw_acs %>% 
  filter(concept == "Means of Transportation to Work by Travel Time to Work") %>%
  pivot_wider(names_from = c(variable, label),
              values_from = c(moe, estimate)) %>% 
  clean_names()
# receipt of food stamps/snap in the past 12 months by disability status for households
acs_snap <- raw_acs %>% 
  filter(concept == "Receipt of Food Stamps/SNAP in the Past 12 Months by Disability Status for Households") %>%
  pivot_wider(names_from = c(variable, label),
              values_from = c(moe, estimate)) %>% 
  clean_names()
rm(raw_acs)

# ==== SUMMARY STATISTICS ====
# (1) How many commuters "walk" to work in Rhode Island? 
acs_transport %>%
  st_drop_geometry() %>%
  summarise(sum = sum(`estimate_b08134_101_estimate_total_walked`))
# 15545

# (2) How many commuters take a "taxicab, motorcycle, bicycle, or other means" to work in Rhode Island?
acs_transport %>%
  st_drop_geometry() %>%
  summarise(sum = sum(`estimate_B08134_111_Estimate!!Total:!!Taxicab, motorcycle, bicycle, or other means:`))
# 10575

# (3) What is the total number of commuters who use either method?
acs_transport %>%
  st_drop_geometry() %>%
  summarise(sum = sum(`estimate_b08134_101_estimate_total_walked` + 
                        `estimate_B08134_111_Estimate!!Total:!!Taxicab, motorcycle, bicycle, or other means:`))
# 26120

# (4) What percentage of households in Rhode Island receive SNAP?
acs_snap %>%
  st_drop_geometry() %>%
  summarise(pct_snap = (sum(estimate_b22010_002_estimate_total_household_received_food_stamps_snap_in_the_past_12_months) / sum(estimate_b22010_001_estimate_total))*100)
# 14%
# ==== DATA CLEANING PART 2 ====

# 1. clean / get rid of extra variables preserving only model variables .
# 2. intersect with ridot bike path data.
# 3. calculate how much linear feet of ridot bike paths are there per geography.
# 4. save that data to use in capstone analysis. 

