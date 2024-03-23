library(ggplot2)
library(dplyr)
library(scales)

# load events with RS and UP country flags
events_rs_vs_up <- readRDS("events/rs_vs_up/events_rs_vs_up.rds")

# group events by day
events_rs_vs_up_by_day <- events_rs_vs_up %>%
  select(SQLDATE, GLOBALEVENTID) %>%
  group_by(SQLDATE) %>%
  summarize(Count = n()) %>%
  filter(SQLDATE >= 20220901 & SQLDATE <= 20231231) %>%
  transform(SQLDATE = as.Date(SQLDATE, "%Y%m%d"))

bar_plot <-
  ggplot(events_rs_vs_up_by_day) +
  geom_bar(aes(x = SQLDATE, y = Count), stat = "identity", fill = "#01BEC4") +
  labs(title = "Time series of Events RS vs UP",
       x = "Date",
       y = "Events per day") +
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
  "events/rs_vs_up/figures/events_rs_vs_up_by_day.png",
  bar_plot,
  width = 10,
  height = 7,
  units = "in",
  dpi = 300
)
