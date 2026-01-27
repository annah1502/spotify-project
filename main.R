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

# Daten bereinigen --------------------------------------------------------
streaming_history_clean <- streaming_history_raw %>% 
  mutate(
    ts = ymd_hms(ts)
  ) %>% 
  filter(
    ms_played != 0
  ) %>% 
  select(-audiobook_title, 
         -audiobook_uri, 
         -audiobook_chapter_uri, 
         -audiobook_chapter_title,
         -incognito_mode)

# Songs und Podcasts aufteilen
song_data <- streaming_history_clean %>% 
  filter(
    is.na(episode_name) & is.na(episode_show_name)
  ) %>% 
  select(-episode_name,
         -episode_show_name,
         -spotify_episode_uri)

podcast_data <- streaming_history_clean %>% 
  filter(
    !is.na(episode_name) & !is.na(episode_show_name)
  ) %>% 
  select(-master_metadata_track_name,
         -master_metadata_album_artist_name,
         -master_metadata_album_album_name,
         -spotify_track_uri)


