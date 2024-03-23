library(ggplot2)
library(dplyr)
library(scales)
library(zoo)

# load events with IS and GZ country flags
events_is_vs_gz <- readRDS("events/events_is_vs_gz.rds")

# group events by day
events_is_vs_gz_by_day <- events_is_vs_gz %>%
  select(SQLDATE, GLOBALEVENTID, AvgTone) %>%
  group_by(SQLDATE) %>%
  summarize(Count = n(), AvgTone = mean(AvgTone)) %>%
  filter(SQLDATE >= 20220901 & SQLDATE <= 20240130 & Count >= 10) %>%
  mutate(SQLDATE = as.Date(SQLDATE, "%Y%m%d"))

# calculate moving average over 7 days to smooth the data
# ChatGPT 3.5 (15.03.2024) I have a rlang dataframe with 2 columns, first is the day (each day once over the span of two years) and then the average tone per day. The average tone is calculated by calculating the average mean of all events that day. The problem is that in my time series, there is a point before it are way less events than after it. So the average or mean before that point is really shaky and after it its way smoother. Do you have an idea how i get the two to match?
events_is_vs_gz_by_day_ma <- events_is_vs_gz_by_day %>%
  ungroup() %>%
  mutate(AvgTone = rollmean(
    AvgTone,
    k = 7,
    align = "center",
    fill = NA
  ))

line_plot_ma <-
  ggplot(events_is_vs_gz_by_day_ma) +
  geom_line(aes(x = SQLDATE, y = AvgTone), stat = "identity") +
  geom_smooth(aes(x = SQLDATE, y = AvgTone), method = 'lm') +
  labs(title = "Average Tone of GZ vs IS events using moving average (7 days)",
       x = "Date",
       y = "Average Tone") +
  theme_minimal() +
  scale_x_date(labels = date_format("%m/%Y"), breaks = date_breaks("1 month")) +
  theme(
    axis.ticks = element_blank(),
    axis.text.x = element_text(angle = 45),
    axis.title.x = element_text(vjust = 6),
    plot.title = element_text(size = 14, hjust = 0.5)
  )

plot(line_plot_ma)

ggsave(
  "maps/events_is_vs_gz_tone_by_day_ma.png",
  line_plot_ma,
  width = 10,
  height = 7,
  units = "in",
  dpi = 300
)