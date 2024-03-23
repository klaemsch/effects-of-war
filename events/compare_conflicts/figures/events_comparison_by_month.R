library(ggplot2)
library(dplyr)
library(scales)

# load events with IS and GZ country flags
events_is_vs_gz <- readRDS("events/events_is_vs_gz.rds")

# load events with RS and UP country flags
events_rs_vs_up <- readRDS("events/events_rs_vs_up.rds")

# load statistics for every month on whole db
num_events_by_month <- readRDS("events/num_events_by_month.rds")

# group events by month
events_is_vs_gz_by_month <- events_is_vs_gz %>%
  select(MonthYear, GLOBALEVENTID) %>%
  group_by(MonthYear) %>%
  summarize(ConflictCount = n()) %>%
  filter(MonthYear >= 202209 & MonthYear <= 202401) %>%
  left_join(num_events_by_month, by = join_by(MonthYear == MonthYear)) %>%
  mutate(
    MonthYear = as.Date(paste(MonthYear, "01", sep = ""), "%Y%m%d"),
    PercCount = ConflictCount / Count * 10,
    Conflict = "ISvsGZ"
  )
  
events_rs_vs_up_by_month <- events_rs_vs_up %>%
  select(MonthYear, GLOBALEVENTID) %>%
  group_by(MonthYear) %>%
  summarize(ConflictCount = n()) %>%
  filter(MonthYear >= 202209 & MonthYear <= 202401) %>%
  left_join(num_events_by_month, by = join_by(MonthYear == MonthYear)) %>%
  mutate(
    MonthYear = as.Date(paste(MonthYear, "01", sep = ""), "%Y%m%d"),
    PercCount = ConflictCount / Count * 10,
    Conflict = "RSvsUP"
  )

events_by_month <- bind_rows(events_is_vs_gz_by_month, events_rs_vs_up_by_month)

bar_plot <-
  ggplot(events_by_month) +
  geom_bar(aes(x = MonthYear, y = PercCount, fill = Conflict), stat = "identity") +
  labs(title = "Comparison of the conflicts Russia vs Ukraine and Isreal vs Gaza over time",
       x = "Month",
       y = "Percentage of conflict in all events [‰] ") +
  theme_minimal() +
  scale_x_date(labels = date_format("%m/%Y"), breaks = date_breaks("1 month")) +
  theme(
    axis.ticks = element_blank(),
    axis.text.x = element_text(angle = 45),
    axis.title.x = element_text(vjust = 6),
    plot.title = element_text(size = 14, hjust = 0.5)
  )

plot(bar_plot)

ggsave(
  "maps/events_comparison_by_month.png",
  bar_plot,
  width = 10,
  height = 7,
  units = "in",
  dpi = 300
)
