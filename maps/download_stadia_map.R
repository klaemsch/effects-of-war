library(ggmap)

borders <- data.frame(
  left = -132.7,
  bottom = -59.7,
  right = 179.9,
  top = 72.6
)

register_stadiamaps(key = "your-key-here")

# boundaries of the map
# lon = -180 -> 180 and lat = -85 -> 85 spans the whole world
world_map <- get_stadiamap(
  bbox = c(
    left = borders$left,
    bottom = borders$bottom,
    right = borders$right,
    top = borders$top
  ),
  zoom = 3,
  maptype = "alidade_smooth"
) %>% ggmap()

saveRDS(world_map, "maps/world_map.rds")