# i used chatGPT 3.5 on 06.02.2024:
# prompt: I have a csv file i want to import via read_csv in r. The file contains up to 5 entries for each domain with a country and a count next to it. I only want the entry with the max count in my dataframe
# another prompt: Now i want to mutate the domain dataframe and add the coordinates i have stored in another dataframe. I can compare the country code to match the data
library(readr)
library(dplyr)

# load domains list
domains <- read_csv(
  "domains/domain_list_new.csv",
  col_types  = c(col_character(),
                 col_character(),
                 col_double())
)

# rename column names
names(domains) <- c("Domain", "FIPSCountryCode", "Count")

# load country data
country_data <- readRDS("./country_data/country_data.rds")

# make sure only one entry per domain persists
# choose the country with the highest count
# then add the coordinates by comparing with the country data frame
# then deselect count column
domains <- domains %>%
  group_by(Domain) %>%
  distinct(Domain, .keep_all = TRUE) %>%
  filter(Count == max(Count)) %>%
  left_join(country_data, by = c("FIPSCountryCode" = "FIPSCountryCode")) %>%
  select(!Count)

# write data to rds
saveRDS(domains, file = "domains/domain_data.rds")

# create a table that compares the number of domains by country
num_domains_by_country <- domains %>% 
  select(Domain, FIPSCountryCode, CountryLatitude, CountryLongitude) %>% 
  group_by(FIPSCountryCode, CountryLatitude, CountryLongitude) %>%
  summarise(occ = n(), .groups = 'drop')