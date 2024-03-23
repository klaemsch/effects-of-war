# this script loads the database, filters it for events with actors Israel and
# Gaza and writes the result into a R data structure. We can then load this
# rds to analyze it in another file

library(dplyr)

# connect to database
db <- dbConnect(SQLite(), "E:/dh/bfdb2.db")

# filter the table for
# IS vs GZ
# GZ vs IS
events_is_vs_gz <- db %>%
  tbl("events") %>%
  filter(
    (Actor1Geo_CountryCode == 'IS' & Actor2Geo_CountryCode == 'GZ') |
    (Actor1Geo_CountryCode == 'GZ' & Actor2Geo_CountryCode == 'IS')
  ) %>%
  collect()

# write data to csv and rds
saveRDS(events_is_vs_gz, file = "events/events_is_vs_gz.rds")

dbDisconnect(db)
