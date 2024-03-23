# I asked ChatGPT 3.5 on 05.02.24
# i have a dataframe in r that holds countries as rows. One column is the ISO country code. Then i have a different dataframe where for each country (row) you have many country code systems. I want to extract the FIPS code from the second table for each country in table 1. I dont want to merge these two, i just want the fips code appended to the first dataframe

library(readr)

# read csv for fips and iso codes
country_codes <-  read_csv("country_data/country_codes.csv")

# this table uses iso
country_coordinates <- read_delim(
  "country_data/country_coordinates.csv",
  delim = "\t",
  escape_double = FALSE,
  col_types = cols(latitude = col_character(),
                   longitude = col_character()),
  trim_ws = TRUE
)

# join data frames on FIPS code and select FIPS, ISO, name and coordinates
country_data <- country_coordinates %>%
  left_join(country_codes, by = c("country" = "ISO3166-1-Alpha-2")) %>%
  select('FIPS',
         'country',
         'name',
         'latitude',
         'longitude')

# rename columns
names(country_data) <- c(
  'FIPSCountryCode',
  'ISOCountryCode',
  'CountryName',
  'CountryLatitude',
  'CountryLongitude'
)

saveRDS(country_data, file = "country_data/country_data.rds")