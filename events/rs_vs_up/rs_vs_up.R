library(dplyr)
library(RSQLite)

# connect to database
db <- dbConnect(SQLite(), "E:/dh/bfdb2.db")

# filter the table for
# RS vs UP
# UP vs RS
events_rs_vs_up <- db %>%
  tbl("events") %>%
  filter(
    (Actor1Geo_CountryCode == 'RS' & Actor2Geo_CountryCode == 'UP') |
      (Actor1Geo_CountryCode == 'UP' & Actor2Geo_CountryCode == 'RS')
  ) %>%
  collect()

# write data to rds
saveRDS(events_rs_vs_up, file = "events/rs_vs_up/events_rs_vs_up.rds")

dbDisconnect(db)