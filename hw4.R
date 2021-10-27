library(sf)
library(tidyverse)
library(janitor)
library(stringr)
library(usethis)

# read in gender inequality data
gi_data <- read_csv("data/gender_inequality.csv", 
                    skip=5,
                    na='..') %>%
  clean_names() %>%
  slice_head(n = 189) 

# clen and wrangle data to produce difference between 2010 and 2019
ineq_diff_data <- gi_data %>%
  select(names(gi_data)[nchar(names(gi_data)) > 3]) %>% 
  rename_all(funs(stringr::str_replace_all(., "x", "y_"))) %>% 
  mutate(gi_ineq_diff = y_2010 - y_2019) %>% 
  select(country, gi_ineq_diff)

# load spatial data
world_shapes <- st_read("data/countries/World_Countries__Generalized_.shp") %>% 
  clean_names()

# join inequality data
data <- world_shapes %>% 
  left_join(ineq_diff_data)

# save data
data %>% 
  st_write(., "data/gi_ineq_data.gpkg",
           layer = 'world_diff_2010_2019')
