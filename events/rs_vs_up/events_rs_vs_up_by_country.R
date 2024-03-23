library(dplyr)
library(readr)
library(rlang)

# load events with IS and GZ country flags
events_rs_vs_up <- readRDS("events/rs_vs_up/events_rs_vs_up.rds")

# group domains together
# get a list of domains and their occurrence count
events_rs_vs_up_by_domain <- events_rs_vs_up %>%
  select(GLOBALEVENTID, source_domain, AvgTone) %>%
  group_by(source_domain) %>%
  summarise(Count = n(), AvgTone = mean(AvgTone))

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

# try to find the country of origin for every domain in the
# events_rs_vs_up_by_domain list using above helper function
events_rs_vs_up_by_domain <- events_rs_vs_up_by_domain %>%
  rowwise() %>%
  mutate(ISOCountryCode = get_country_code_from_domain(source_domain))

# filter, so remaining is only not NA values
# summarize by country
events_rs_vs_up_by_country <- events_rs_vs_up_by_domain %>%
  filter(!is.na(ISOCountryCode)) %>%
  group_by(ISOCountryCode) %>%
  summarise(TotalOccurrences = sum(Count), AvgTone = mean(AvgTone))

# country_data maps each country to coordinates
country_data <- readRDS("country_data/country_data.rds")

# add coordinate information to 
events_rs_vs_up_by_country <- events_rs_vs_up_by_country %>%
  left_join(country_data, by = c("ISOCountryCode" = "ISOCountryCode"))

# write data to rds
saveRDS(events_rs_vs_up_by_country, file = "events/rs_vs_up/events_rs_vs_up_by_country.rds")
