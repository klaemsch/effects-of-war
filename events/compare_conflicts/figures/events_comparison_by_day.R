library(ggplot2)
library(dplyr)
library(scales)

# load events with IS and GZ country flags
events_is_vs_gz <- readRDS("events/is_vs_gz/events_is_vs_gz.rds")

# load events with RS and UP country flags
events_rs_vs_up <- readRDS("events/rs_vs_up/events_rs_vs_up.rds")

# group events by day
events_is_vs_gz_by_day <- events_is_vs_gz %>%
  select(SQLDATE, GLOBALEVENTID) %>%
  group_by(SQLDATE) %>%
  summarize(Count = n()) %>%
  filter(SQLDATE >= 20220901 & SQLDATE <= 20231231) %>%
  mutate(
    SQLDATE = as.Date(SQLDATE, "%Y%m%d"),
      Conflict = "ISvsGZ"
    )

# group events by day
events_rs_vs_up_by_day <- events_rs_vs_up %>%
  select(SQLDATE, GLOBALEVENTID) %>%
  group_by(SQLDATE) %>%
  summarize(Count = n()) %>%
  filter(SQLDATE >= 20220901 & SQLDATE <= 20231231) %>%
  mutate(
    SQLDATE = as.Date(SQLDATE, "%Y%m%d"),
    Conflict = "RSvsUP"
  )

events_by_day <- bind_rows(events_is_vs_gz_by_day, events_rs_vs_up_by_day)

bar_plot <-
  ggplot(events_by_day) +
  geom_bar(aes(x = SQLDATE, y = Count, fill = Conflict), stat = "identity") +
  labs(title = "Time series of Events GZ vs IS",
       x = "Date",
       y = "Events per day") +
  theme_minimal() +
  scale_x_date(labels = date_format("%d.%m.%Y"), breaks = date_breaks("1 month")) +
  theme(
    axis.ticks = element_blank(),
    axis.text.x = element_text(angle = 45),
    axis.title.x = element_text(vjust = 6),
    plot.title = element_text(size = 14, hjust = 0.5)
  )

plot(bar_plot)

ggsave(
  "maps/events_comparison_by_day.png",
  bar_plot,
  width = 10,
  height = 7,
  units = "in",
  dpi = 300
)
