library(ggplot2)
library(dplyr)
library(scales)

# load events with RS and UP country flags
events_rs_vs_up <- readRDS("events/events_rs_vs_up.rds")

# group events by day
events_rs_vs_up_by_month <- events_rs_vs_up %>%
  select(MonthYear, GLOBALEVENTID) %>%
  group_by(MonthYear) %>%
  summarize(Count = n()) %>%
  filter(MonthYear >= 202209 & MonthYear <= 202401) %>%
  mutate(MonthYear = as.Date(paste(MonthYear, "01", sep = ""), "%Y%m%d"))

bar_plot <-
  ggplot(events_rs_vs_up_by_month) +
  geom_bar(aes(x = MonthYear, y = Count), stat = "identity") +
  labs(title = "Time series of Events RS vs UP",
       x = "Date",
       y = "Events per Month") +
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
  "maps/events_rs_vs_up_by_month.png",
  bar_plot,
  width = 10,
  height = 7,
  units = "in",
  dpi = 300
)
