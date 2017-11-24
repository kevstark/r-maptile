if(!"RgoogleMaps" %in% library()$results[, 1]) { install.packages("RgoogleMaps") }
if(!"imager" %in% library()$results[, 1]) { install.packages("imager") }
if(!"ggmap" %in% library()$results[, 1]) { install.packages("ggmap") }
if(!"dplyr" %in% library()$results[, 1]) { install.packages("dplyr") }; library("dplyr")

# Create single satellite image from stitched tiles at max zoom
write.tilemapimage <- function(output, lat, lon, 
                          tile_dim = c(1, 1), 
                          z = 20, 
                          url = "http://mt1.google.com/vt/lyrs=s", 
                          tile_dir = ".tiles", keep_tiles = FALSE, 
                          verbose = FALSE) {
  cen <- c(lat, lon)
  
  if(verbose) { message(paste0("  Initialising tile cache '", tile_dir, "'")) }
  # Remove working directory if exists
  unlink(tile_dir, recursive = TRUE, force=TRUE)
  # Create working directory
  dir.create(tile_dir)

  if(verbose) { message(paste0("  Querying ", tile_dim[1] * tile_dim[2], " tiles at z", z, " from map server '", url, "'")) }
  tile_img <- RgoogleMaps::GetMapTiles(
    center = as.numeric(cen), zoom = z, nTiles = tile_dim, 
    urlBase = url,
    tileDir = tile_dir, tileExt = ".png", CheckExistingFiles = FALSE)

  # List all downloaded PNGs
  tile_file <- list.files(paste0(tile_dir, "/"), pattern = "*.png$", full.names = TRUE, ignore.case = TRUE)

  if(verbose) { message(paste0("  Converting ", format(length(tile_file), big.mark=","), " tile images")) }

  # Rename as correct file type (JPG)
  file.rename(tile_file, sub("\\.png$", "\\.jpg", tile_file))
  # Convert from JPG back to PNG file format
  sapply(tile_file, function(x) { imager::load.image(sub("\\.png$", "\\.jpg", x)) %>% imager::save.image(x) })
  
  if(verbose) { message(paste0("  Writing stitched file '", output, "'")) }
  jpeg(filename = output, width = 640 * tile_dim[1], height = 640 * tile_dim[2], quality = 99)
  RgoogleMaps::PlotOnMapTiles(tile_img)
  dev.off()
  if(verbose) { message(paste0("  ", format(file.size(output), big.mark = ","), " bytes written")) }
  
  # Cleanup
  if(!keep_tiles) {
    if(verbose) { message("  Removing tile cache") }
    unlink(tile_dir, recursive = TRUE, force=TRUE)
  }
  return(output)
}

# Download and plot a single map tile to a jpg file
write.mapimage <- function(output, lat, lon, 
                      z, maptype = "satellite", 
                      verbose = FALSE) {
  cen = c(lon, lat)
  if(verbose) { message(paste0("  Querying tile at z", z, " from googlemap server")) }
  jpeg(output, width = 1280, height = 1280, quality = 90)
  ggmap::get_googlemap(scale = 2, center = as.numeric(cen), zoom = z, maptype = maptype) %>% ggmap::ggmap() %>% print()
  # Sys.sleep(2)
  dev.off()
  if(verbose) { message(paste0("  ", format(file.size(output), big.mark = ","), " bytes written")) }
  return(output)
}


