# Daten einlesen
library(jsonlite)
library(dplyr)
library(lubridate)

streaming_history_raw <- c("~/spotify-project/data/raw/Streaming_History_Audio_2016-2020_0.json", 
                       "~/spotify-project/data/raw/Streaming_History_Audio_2020-2022_1.json",
                       "~/spotify-project/data/raw/Streaming_History_Audio_2022-2023_2.json",
                       "~/spotify-project/data/raw/Streaming_History_Audio_2023-2026_3.json")
  

streaming_history_raw <- lapply(streaming_history_raw, fromJSON) %>% 
                      bind_rows()

summary(streaming_history_raw)

# Daten bereinigen

streaming_history_clean <- streaming_history_raw %>% 
  mutate(
    ts = ymd_hms(ts)
  )


