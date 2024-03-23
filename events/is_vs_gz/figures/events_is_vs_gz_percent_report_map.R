library(ggmap)
library(ggplot2)
library(dplyr)
library(ggrepel)
library(maps)

# is vs gz events by country of origin
events_is_vs_gz_by_country <-
  readRDS("events/is_vs_gz/events_is_vs_gz_by_country.rds")

# maps all events to country
domain_to_country_map <- readRDS("events/domain_to_country_map.rds")

# join and calculate percentage of reports of the whole reporting done by the country
events_is_vs_gz_by_country <- events_is_vs_gz_by_country %>%
  rename(ISvsGZOccurences = TotalOccurrences) %>%
  merge(domain_to_country_map) %>%
  mutate(
    PercOccur = ISvsGZOccurences / TotalOccurrences * 100
  )

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
events_is_vs_gz_by_country <- events_is_vs_gz_by_country %>%
  select(FIPSCountryCode,
         CountryName,
         CountryLatitude,
         CountryLongitude,
         PercOccur) %>%
  mutate(
    CountryLatitude = as.numeric(CountryLatitude),
    CountryLongitude = as.numeric(CountryLongitude),
  ) %>%
  filter(
    !is.na(CountryLatitude) &
      !is.na(CountryLongitude) &
      CountryLatitude >= borders$bottom &
      CountryLatitude <= borders$top &
      CountryLongitude >= borders$left &
      CountryLongitude <= borders$right
  )

events_is_vs_gz_by_country$CountryName <- gsub("United Kingdom", "UK", events_is_vs_gz_by_country$CountryName)
events_is_vs_gz_by_country$CountryName <- gsub("United States", "USA", events_is_vs_gz_by_country$CountryName)
events_is_vs_gz_by_country$CountryName <- gsub("Trinidad and Tobago", "Trinidad", events_is_vs_gz_by_country$CountryName)
events_is_vs_gz_by_country$CountryName <- gsub("Saint Vincent and the Grenadines", "Saint Vincent", events_is_vs_gz_by_country$CountryName)
events_is_vs_gz_by_country$CountryName <- gsub("Myanmar [Burma]", "Myanmar", events_is_vs_gz_by_country$CountryName)
events_is_vs_gz_by_country$CountryName <- gsub("Macedonia [FYROM]", "North Macedonia", events_is_vs_gz_by_country$CountryName)

map_data <- events_is_vs_gz_by_country %>%
  left_join(mapdata, by = c("CountryName" = "region"), keep=TRUE)

test <- map_data %>% filter(is.na(region))

events_is_vs_gz_percent_report_map <- world_map +
  geom_polygon(
    data = map_data,
    aes(
      x = long,
      y = lat,
      group = group,
      fill = PercOccur
    ),
    alpha = 0.5
  ) + 
  scale_fill_gradient(low = "red", high = "blue", name = "Percentage of Reports", na.value = "grey") +
  labs(title = "Share of IS vs GZ reports out of all reports",
       caption = "The share of IS and GZ reports is shown here for each country\nin relation to all reports published in the country") +
  theme_void() +
  theme(
    axis.text = element_blank(),
    axis.title = element_blank(),
    axis.ticks = element_blank(),
    legend.position = "bottom",
    plot.title = element_text(size = 20, hjust = 0.5)
  )


plot(events_is_vs_gz_percent_report_map)

ggsave(
  "events/is_vs_gz/figures/events_is_vs_gz_percent_report_map.png",
  events_is_vs_gz_percent_report_map,
  width = 10,
  height = 7,
  units = "in",
  dpi = 300
)
