# [Spotify "Wrapped"]{.underline}

Forschungsfragen:

-   Wie hat sich mein Musik-Streaming-Verhalten im Zeitverlauf verändert und welche Muster lassen sich in Bezug auf Tageszeit, Jahreszeit und Skip-Verhalten erkennen?

-   Was sind meine meistgehörtesten Lieder, Künstler und Genres, was haben sie gemeinsam?

Vorgehen:

-   Persönliche streaming_history bei Spotify anfragen

-   json-File einlesen und säubern (z.B. aufteilen nach Songs und Podcasts, Songs mit 0 ms_played rausfiltern)

-   über die Spotify API weitere Song-Daten wie popularity ziehen
