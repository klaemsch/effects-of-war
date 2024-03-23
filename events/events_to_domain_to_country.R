# this script opens the events table and groups the source domains, resulting in
# a list of the specific domain and how many events it contributed to the db
# then the domains get mapped to a country and coordinates, resulting in a 
# overview where the data in GDELT is coming from

library(dplyr)
library(readr)
library(rlang)

# connect to database
db <- dbConnect(SQLite(), "E:/dh/bfdb2.db")

# group domains together
# get a list of domains and their occurrence count
events_by_domain <- db %>%
  tbl("events") %>%
  select(GLOBALEVENTID, source_domain) %>%
  group_by(source_domain) %>%
  summarise(Count = n()) %>%
  collect()

# write data to csv and rds
write_csv(events_by_domain, "events/events_by_domain.csv")
saveRDS(events_by_domain, file = "events/events_by_domain.rds")

# reload events by domain, if not previously build
events_by_domain <- readRDS("events/events_by_domain.rds")

# domain_data maps each domain to a country and coordinates
domain_data <- readRDS("domains/domain_data.rds")

# create new environment (hashmap for fast access)
domain_to_country_hashmap <- new.env()

# fill hashmap with domain_data
# maps a domain to a countr code in ISO format
domain_to_country_hashmap <- list2env(
  setNames(
    as.list(domain_data$ISOCountryCode),
    domain_data$Domain
  ),
  envir = domain_to_country_hashmap
)

# this helper function tries to find a match for a given domain
# first, tries to match directly
# then strips the www. and any subdomain prefix and tries again
# could be perfected in future to match even more
get_country_code_from_domain <- function(domain) {
  country_code <- env_get(domain_to_country_hashmap, domain, NA)
  if (!is.na(country_code)) return(country_code)
  subdomain_pattern <- "^(www\\.|[^.]+\\.)"
  domain_without_subdomains <- sub(subdomain_pattern, "", domain)
  country_code <- env_get(domain_to_country_hashmap, domain_without_subdomains, NA)
}

# try to find the countr of origin for every domain in the events_by_domain list
# using above helper function
domain_to_country_map <- events_by_domain %>%
  rowwise() %>%
  mutate(ISOCountryCode = get_country_code_from_domain(source_domain))

# filter, so remaining is only not NA values
domain_to_country_map <- domain_to_country_map %>%
  filter(!is.na(ISOCountryCode)) %>%
  group_by(ISOCountryCode) %>%
  summarise(TotalOccurrences = sum(Count))

# country_data maps each country to coordinates
country_data <- readRDS("country_data/country_data.rds")

# add coordinate information to 
domain_to_country_map <- domain_to_country_map %>%
  left_join(country_data, by = c("ISOCountryCode" = "ISOCountryCode"))

# write data to rds
saveRDS(domain_to_country_map, file = "events/domain_to_country_map.rds")

dbDisconnect(db)
