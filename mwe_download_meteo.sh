#!/bin/bash

# The following Bash snippet demonstrates the core functionality of the script
# download_meteo.sh data for a single day using one of the supported models
# (nam12, gfs0p25, or hrrr).

start_date='2024-10-07'   # YYYY-MM-DD
end_date='2024-10-07'     # YYYY-MM-DD (inclusive)
meteo_type="hrrr"         # Options: 'hrrr', 'nam12', 'gfs0p25'
savedir="/tmp"            # Local directory to save downloaded files

# Extract year, month, and day components from start_date
read -r y m d <<< "$(date '+%Y %m %d' -d "$start_date")"

if [ "$meteo_type" = "nam12" ]; then
    # For 'nam12', URL pattern includes the date and suffix '_nam12'
    urlArray+=(
        "https://www.ready.noaa.gov/data/archives/nam12/${y}${m}${d}_nam12"
    )
elif [ "$meteo_type" = "gfs0p25" ]; then
    # For 'gfs0p25', URL pattern includes the date and suffix '_gfs0p25'
    urlArray+=(
        "https://www.ready.noaa.gov/data/archives/nam12/${y}${m}${d}_gfs0p25"
    )
elif [ "$meteo_type" = "hrrr" ]; then
    # For 'hrrr', four URLs per day split into time blocks (00-05, 06-11, etc.)
    urlArray+=(
        "https://www.ready.noaa.gov/data/archives/hrrr/${y}${m}${d}_00-05_hrrr"
        "https://www.ready.noaa.gov/data/archives/hrrr/${y}${m}${d}_06-11_hrrr"
        "https://www.ready.noaa.gov/data/archives/hrrr/${y}${m}${d}_12-17_hrrr"
        "https://www.ready.noaa.gov/data/archives/hrrr/${y}${m}${d}_18-23_hrrr"
    )
else
    echo "unknown meteo data type '$meteo_type'"
    exit 1
fi

for fileaddr in "${urlArray[@]}"; do
    wget -P $savedir $fileaddr
done