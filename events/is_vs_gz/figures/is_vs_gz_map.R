library(readr)

# load events
events_is_vs_gz <- readRDS("events/events_is_vs_gz.rds")

num_events_by_actor_countries <- readRDS("events/num_entries_by_actor_countries.rds")

# extract domain from source url
domain_df <- urltools::suffix_extract(urltools::domain(events_is_vs_gz$SOURCEURL))
events_is_vs_gz$DOMAIN <- paste(domain_df$domain, domain_df$suffix, sep=".")

# load domain data
domains <- readRDS("domains/domain_data.rds")

map_events <- events_is_vs_gz %>%
  left_join(domains, by = c("DOMAIN" = "Domain")) %>%
  select(FIPSCountryCode, CountryLatitude, CountryLongitude, AvgTone, SQLDATE) %>%
  group_by(FIPSCountryCode, CountryLatitude, CountryLongitude) %>%
  summarise(Count = n(), Tone = mean(AvgTone), .groups = 'drop') %>%
  left_join(num_events_by_actor_countries, by = c("FIPSCountryCode" = "country_code"))

write_csv(map_events, "csv/is_vs_gz_domain_map_with_country_occ.csv")

#mean(map_events$Tone)
#sum(map_events$Tone * map_events$Count) / sum(map_events$Count)
#sum(map_events$Count)
