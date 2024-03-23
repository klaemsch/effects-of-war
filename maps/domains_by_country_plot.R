library(ggplot2)
library(dplyr)

domain_data <- readRDS("domains/domain_data.rds")

num_domains_by_country <- domain_data %>%
  select(Domain, ISOCountryCode) %>%
  group_by(ISOCountryCode) %>%
  summarise(occ = n(), .groups = 'drop')

# get the 10 countries with the most domains
top_countries <- num_domains_by_country %>%
  slice_max(order_by = occ, n = 10) %>%
  mutate(ISOCountryCode = factor(ISOCountryCode,
                                  levels = ISOCountryCode[order(occ, decreasing = TRUE)]))

box_plot <-
  ggplot(top_countries, aes(x = ISOCountryCode, y = occ)) +
  geom_col() +
  labs(title = "Top 10 Countries: Distribution of Domains within GDELT",
       x = "Country",
       y = "Number of Domains") +
  theme_minimal() + 
  theme(
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    axis.line.y = element_blank(),
    axis.text.x = element_text(angle = 0, vjust = 11),
    axis.title.x = element_text(vjust = 8),
    plot.title = element_text(size = 14, hjust = 0.5, vjust = -4)
  )

plot(box_plot)

ggsave(
  "maps/plot_domains_by_country.png",
  box_plot,
  width = 10,
  height = 7,
  units = "in",
  dpi = 300
)
