library(httr)
library(jsonlite)
library(dplyr)
library(purrr)

# Funktion
get_track_metadata <- function(artist, track) {
  Sys.sleep(1.1)  # Wichtig!
  
  query <- paste0('artist:"', artist, '" AND recording:"', track, '"')
  
  response <- GET(
    "https://musicbrainz.org/ws/2/recording/",
    query = list(query = query, fmt = "json", limit = 1),
    add_headers(`User-Agent` = "R-Spotify-Analysis/1.0 (annaheid2003@gmail.com")
  )
  
  if (status_code(response) != 200 || length(content(response)$recordings) == 0) {
    return(tibble(
      artist_query = artist,
      track_query = track,
      release_date = NA,
      tags = NA
    ))
  }
  
  recording <- content(response)$recordings[[1]]
  
  tags <- if (!is.null(recording$tags) && length(recording$tags) > 0) {
    paste(sapply(recording$tags, function(x) x$name), collapse = "; ")
  } else {
    NA
  }
  
  tibble(
    artist_query = artist,
    track_query = track,
    release_date = recording$`first-release-date` %||% NA,
    tags = tags
  )
}

# Deine Songs vorbereiten (nur unique Songs)
songs_to_lookup <- song_data %>%
  distinct(
    master_metadata_album_artist_name,
    master_metadata_track_name
  ) %>%
  filter(
    !is.na(master_metadata_album_artist_name),
    !is.na(master_metadata_track_name)
  ) %>%
  head(20)


track_metadata <- map2_dfr(
  songs_to_lookup$master_metadata_album_artist_name,
  songs_to_lookup$master_metadata_track_name,
  ~ {
    cat(".")
    get_track_metadata(.x, .y)
  }
)

# Zusammenführen
songs_with_metadata <- songs_to_lookup %>%
  left_join(
    track_metadata,
    by = c(
      "master_metadata_album_artist_name" = "artist_query",
      "master_metadata_track_name" = "track_query"
    )
  )

# Ergebnis
glimpse(songs_with_metadata)

# Speichern
saveRDS(songs_with_metadata, 
        "~/spotify-project/data/processed/songs_with_musicbrainz_metadata.rds")


# alle songs --------------------------------------------------------------
# Batches von 100 Songs
batch_size <- 100
n_batches <- ceiling(nrow(songs_unique) / batch_size)

all_metadata <- list()

for (i in 1:n_batches) {
  cat(sprintf("\nBatch %d/%d\n", i, n_batches))
  
  start_idx <- (i - 1) * batch_size + 1
  end_idx <- min(i * batch_size, nrow(songs_unique))
  
  batch <- songs_unique[start_idx:end_idx, ]
  
  batch_metadata <- map2_dfr(
    batch$master_metadata_album_artist_name,
    batch$master_metadata_track_name,
    get_track_metadata
  )
  
  all_metadata[[i]] <- batch_metadata
  
  # Zwischenspeichern
  saveRDS(all_metadata, "~/spotify-project/data/temp/metadata_progress.rds")
}

final_metadata <- bind_rows(all_metadata)

