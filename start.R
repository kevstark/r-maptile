if(!"yaml" %in% library()$results[, 1]) { install.packages("yaml") }
if(!"dplyr" %in% library()$results[, 1]) { install.packages("dplyr") }; library(dplyr)
if(!"purrr" %in% library()$results[, 1]) { install.packages("purrr") }; library(purrr)

# Load map functions
source("mapimage.R")

# Prompt user to select config file
config_file <- choose.files(
  default = "config.yml", 
  caption = "Select location config file:", 
  multi = FALSE, 
  filters = matrix(c("YAML (*.yml, *.yaml)", "*.yml;*.yaml", "All Files (*.*)", "*.*"), ncol = 2, byrow = TRUE), 
  index = 1)

if(length(config_file) != 1) { stop("Select a location config file to process.", call. = FALSE) }

# Read the location list from config
locations <- yaml::yaml.load_file(config_file)

# Extract the tile definitions
tile_loc <- map(locations, "tile")
# Build argument list for pwalk
args <- list(
  output = map2_chr(names(locations), tile_loc_z, ~ paste0(.x, "_z", .y, ".tile_", format(Sys.Date(), "%Y%m%d"), ".jpg")),
  lat = map(locations, "lat"),
  lon = map(locations, "lon"),
  z = map(tile_loc, "z"),
  tile_dim = map(tile_loc, "dim"),
  verbose = TRUE
)
# Execute each stitch and write to file
pwalk(args, write.tilemapimage)


# Extract the static map definitions
stat_loc <- map(locations, "single")
# Build argument list for pwalk
args = list(
  output = map2_chr(names(locations), stat_loc_z, ~ paste0(.x, "_z", .y, "_", format(Sys.Date(), "%Y%m%d"), ".jpg")),
  lat = map(locations, "lat"),
  lon = map(locations, "lon"),
  z = map(stat_loc, "z"),
  maptype = map(stat_loc, "maptype"),
  verbose = TRUE
)
# Execute each download and write to file
pwalk(args, write.mapimage)
