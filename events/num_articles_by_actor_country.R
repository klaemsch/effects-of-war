library(dplyr)

# connect to database
db <- dbConnect(SQLite(), "db/bfdb.db")

# look only at the actor columns and save as subtable
subtable_actor1_actor2_country_code <- db %>%
  tbl("events") %>%
  select(Actor1Geo_CountryCode, Actor2Geo_CountryCode)

# group and count actor 1 entries
actor1_country_code_filtered <- subtable_actor1_actor2_country_code %>%
  select(Actor1Geo_CountryCode) %>%
  filter(!is.null(Actor1Geo_CountryCode)) %>%
  group_by(country_code = Actor1Geo_CountryCode) %>%
  summarise(count = n())

# group and count actor 2 entries
actor2_country_code_filtered <- subtable_actor1_actor2_country_code %>%
  select(Actor2Geo_CountryCode) %>%
  filter(!is.null(Actor2Geo_CountryCode)) %>%
  group_by(country_code = Actor2Geo_CountryCode) %>%
  summarise(count = n())
  
# sum actor 1 and 2 counts
num_entries_by_actor_countries <- actor1_country_code_filtered %>%
  union(actor2_country_code_filtered) %>%
  group_by(country_code) %>%
  summarise(total_occurrences = sum(count)) %>%
  collect()

# the result maps each country to the number of occurrences in the events
# table as actor1 and actor2 combined

# write data to csv and rds
write_csv(num_entries_by_actor_countries, "events/num_entries_by_actor_countries.csv")
saveRDS(num_entries_by_actor_countries, file = "events/num_entries_by_actor_countries.rds")

dbDisconnect(db)