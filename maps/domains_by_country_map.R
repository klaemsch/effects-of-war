library(ggmap)
library(dplyr)
library(ggrepel)

borders <- data.frame(
  left = -132.7,
  bottom = -59.7,
  right = 179.9,
  top = 72.6
)

domain_data <- readRDS("domains/domain_data.rds")

num_domains_by_country <- domain_data %>%
  select(Domain, FIPSCountryCode, CountryLatitude, CountryLongitude) %>%
  group_by(FIPSCountryCode, CountryLatitude, CountryLongitude) %>%
  summarise(occ = n(), .groups = 'drop') %>%
  mutate(
    CountryLatitude = as.numeric(CountryLatitude),
    CountryLongitude = as.numeric(CountryLongitude)
  ) %>%
  filter(
    !is.na(CountryLatitude) &
      !is.na(CountryLongitude) &
      CountryLatitude >= borders$bottom &
      CountryLatitude <= borders$top &
      CountryLongitude >= borders$left &
      CountryLongitude <= borders$right
  )

# get the 10 countries with the most domains
top_countries <- num_domains_by_country %>%
  slice_max(order_by = occ, n = 10)

register_stadiamaps(key = "b06d85a9-86c8-492c-9996-87272d5b9864")

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

scatter_plot <- world_map +
  geom_point(
    data = num_domains_by_country,
    aes(x = CountryLongitude,
        y = CountryLatitude,
        size = occ),
    color = "red"
  ) +
  geom_text_repel(
    data = top_countries,
    aes(label = occ, x = CountryLongitude, y = CountryLatitude),
    size = 3,
    point.size = NA,
  ) +
  scale_size_continuous(range = c(1, 10)) +  # Adjust the size range as needed
  labs(
    title = "Global distribution of domains within GDELT",
    caption = "GDELT places domains in countries where they report the most.\n This is an overview of the divercity/indivercity of the distribution of those domains",
    size = "Number of Domains"
  ) +
  theme_void() +
  theme(
    axis.text = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    legend.position = "bottom",
    plot.title = element_text(size = 20, hjust = 0.5)
  )


plot(scatter_plot)
ggsave(
  "maps/map_domains_by_country.png",
  scatter_plot,
  width = 10,
  height = 7,
  units = "in",
  dpi = 300
)

