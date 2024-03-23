library(ggplot2)
library(dplyr)
library(scales)
library(zoo)

# load events with IS and GZ country flags
events_is_vs_gz <- readRDS("events/events_is_vs_gz.rds")

# group events by day
events_is_vs_gz_by_month <- events_is_vs_gz %>%
  select(SQLDATE, GLOBALEVENTID, AvgTone) %>%
  filter(SQLDATE >= 20220901 &
           SQLDATE <= 20240130 & AvgTone < 8 & AvgTone > -18) %>%
  mutate(SQLDATE = as.Date(SQLDATE, "%Y%m%d")) %>%
  mutate(Month = format(SQLDATE, "%Y%m"))

box_plot <-
  ggplot(events_is_vs_gz_by_month) +
  geom_boxplot(aes(x = Month, y = AvgTone)) +
  stat_summary(
    fun = mean,
    aes(x = Month, y = AvgTone),
    geom = "point",
    shape = 23,
    size = 4
  ) +
  scale_y_continuous(breaks = pretty_breaks(n = 5)) +
  labs(title = "Average Tone of GZ vs IS events",
       x = "Month",
       y = "Average Tone") +
  theme_minimal() +
  theme(
    axis.ticks = element_blank(),
    axis.text.x = element_text(angle = 45),
    axis.title.x = element_text(vjust = 6),
    plot.title = element_text(size = 14, hjust = 0.5)
  )

plot(box_plot)

ggsave(
  "maps/events_is_vs_gz_tone_by_day_ma_box.png",
  box_plot,
  width = 10,
  height = 7,
  units = "in",
  dpi = 300
)
