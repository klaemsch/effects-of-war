library(ggmap)
library(ggplot2)
library(dplyr)
library(ggrepel)
library(maps)

# load number of events per
events_rs_vs_up_by_country <-
  readRDS("events/rs_vs_up/events_rs_vs_up_by_country.rds")

# load map
world_map <- readRDS("maps/world_map.rds")

# get country polygon data
mapdata <- map_data("world")

# map borders
borders <- data.frame(
  left = -132.7,
  bottom = -59.7,
  right = 179.9,
  top = 72.6
)

# filter and mutate
# join with region/country polygon data
events_rs_vs_up_by_country <- events_rs_vs_up_by_country %>%
  select(FIPSCountryCode,
         CountryName,
         CountryLatitude,
         CountryLongitude,
         AvgTone,
         TotalOccurrences) %>%
  mutate(
    CountryLatitude = as.numeric(CountryLatitude),
    CountryLongitude = as.numeric(CountryLongitude),
    #WeightedAvgTone = AvgTone / TotalOccurrences * 1000,
    #NormalizedWeightedAvgTone = (WeightedAvgTone / max(WeightedAvgTone)) * 10
  ) %>%
  filter(
    !is.na(CountryLatitude) &
      !is.na(CountryLongitude) &
      CountryLatitude >= borders$bottom &
      CountryLatitude <= borders$top &
      CountryLongitude >= borders$left &
      CountryLongitude <= borders$right &
      TotalOccurrences >= 50
  )

events_rs_vs_up_by_country$CountryName <- gsub("United Kingdom", "UK", events_rs_vs_up_by_country$CountryName)
events_rs_vs_up_by_country$CountryName <- gsub("United States", "USA", events_rs_vs_up_by_country$CountryName)
events_rs_vs_up_by_country$CountryName <- gsub("Trinidad and Tobago", "Trinidad", events_rs_vs_up_by_country$CountryName)
events_rs_vs_up_by_country$CountryName <- gsub("Saint Vincent and the Grenadines", "Saint Vincent", events_rs_vs_up_by_country$CountryName)
events_rs_vs_up_by_country$CountryName <- gsub("Myanmar [Burma]", "Myanmar", events_rs_vs_up_by_country$CountryName)
events_rs_vs_up_by_country$CountryName <- gsub("Macedonia [FYROM]", "North Macedonia", events_rs_vs_up_by_country$CountryName)

map_data <- events_rs_vs_up_by_country %>%
  left_join(mapdata, by = c("CountryName" = "region"), keep=TRUE)

test <- map_data %>% filter(is.na(region))

events_rs_vs_up_tone_map <- world_map +
  geom_polygon(
    data = map_data,
    aes(
      x = long,
      y = lat,
      group = group,
      fill = AvgTone
    ),
    alpha = 0.5
  ) + 
  scale_fill_gradient(low = "red", high = "blue", name = "AvgTone", na.value = "grey") +
  labs(title = "Global distribution of domains within GDELT",
       caption = "GDELT places domains in countries where they report the most.\n This is an overview of the divercity/indivercity of the distribution of those domains",
       size = "Number of Domains") +
  theme_void() +
  theme(
    axis.text = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    legend.position = "bottom",
    plot.title = element_text(size = 20, hjust = 0.5)
  )


plot(events_rs_vs_up_tone_map)

ggsave(
  "events/rs_vs_up/figures/events_rs_vs_up_tone_map.png",
  events_rs_vs_up_tone_map,
  width = 10,
  height = 7,
  units = "in",
  dpi = 300
)
