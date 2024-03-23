library(ggmap)
library(dplyr)
library(ggrepel)

borders <- data.frame(
  left = -132.7,
  bottom = -59.7,
  right = 179.9,
  top = 72.6
)

domain_to_country_map <- readRDS("events/domain_to_country_map.rds")

num_domains_by_country <- domain_to_country_map %>%
  mutate(
    CountryLatitude = as.numeric(CountryLatitude),
    CountryLongitude = as.numeric(CountryLongitude),
    TotalOccurrences = round(TotalOccurrences/1000000, 3)
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
  slice_max(order_by = TotalOccurrences, n = 10)

world_map <- readRDS("maps/world_map.rds")

scatter_plot <- world_map +
  geom_point(
    data = num_domains_by_country,
    aes(x = CountryLongitude,
        y = CountryLatitude,
        size = TotalOccurrences),
    color = "red"
  ) +
  geom_text_repel(
    data = top_countries,
    aes(label = TotalOccurrences, x = CountryLongitude, y = CountryLatitude),
    size = 3,
    point.size = NA,
  ) +
  scale_size_continuous(range = c(1, 10)) +  # Adjust the size range as needed
  labs(title = "Global distribution of origin of reports within GDELT (n=59M)",
       caption = "These are the countries, that contribute to GDELT the most.\n It shows the divercity/indivercity of the dataset.",
       size = "Number of Domains in Million") +
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
  "maps/map_event_domains_by_country.png",
  scatter_plot,
  width = 10,
  height = 7,
  units = "in",
  dpi = 300
)
