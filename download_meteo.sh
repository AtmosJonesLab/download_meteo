#!/bin/bash

start_date='2024-10-07'   # YYYY-MM-DD
end_date='2024-10-07'     # YYYY-MM-DD (inclusive)
meteo_type="hrrr"         # Options: 'hrrr', 'nam12', 'gfs0p25'
savedir="/tmp"            # Local directory to save downloaded files

# Check if start_date is earlier than end_date
if [ $(date -d "$start_date" +%s) -gg $(date -d "$end_date" +%s) ]; then
    echo "start_date ($start_date) is greater than end_date ($end_date)"
    exit 1
fi

urlArray=() # Initialize an empty array to hold URLs

# Loop over each day from start_date to end_date (inclusive)
while [[ $(date -d "$start_date" +%s) -le $(date -d "$end_date" +%s) ]]; do
    # Extract year, month, and day components from current date
    read -r y m d <<< "$(date '+%Y %m %d' -d "$start_date")"

    if [ "$meteo_type" = "nam12" ]; then
        urlArray+=(
            "https://www.ready.noaa.gov/data/archives/nam12/${y}${m}${d}_nam12"
        )
    elif [ "$meteo_type" = "gfs0p25" ]; then
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

    # Increment the date by one day for the next iteration
    start_date=$(date --date "$start_date + 1 day" +"%Y-%m-%d")
done

# Print all the URLs that will be downloaded (for verification)
printf '%s\n' "${urlArray[@]}"

# Check if the save directory exists; if not, exit with an error
if [ ! -d "$savedir" ]; then
    echo "$savedir does not exist."
    exit 1
fi

# Prompt user to confirm downloading all files to the save directory
read -p "download ${#urlArray[@]} files to $savedir? [y/N] " response

case "$response" in
    # If user types 'y', 'Y', 'yes', or 'YES', proceed with downloading
    [yY][eE][sS]|[yY])
        echo "Downloading..."
        ;;
    *)
        echo "Exiting."
        exit 1
        ;;
esac


download_counter=0  # Initialize a counter for successful downloads

# Loop over each URL in the array to download files
for fileaddr in "${urlArray[@]}"; do
    # Split the URL by '/' into an array of parts
    IFS='/' read -ra parts <<< "$fileaddr"

    # Construct the full path for the downloaded file using the last part of the URL (filename)
    fname=$(realpath "${savedir}/${parts[${#parts[@]}-1]}")

    # If the file already exists, skip downloading it
    if [ -f "$fname" ]; then
        echo "$fname exists. skipping download..."
        continue
    fi

    # Use wget to download the file into the save directory
    wget -P $savedir $fileaddr

    # If wget succeeded (exit status 0), increment the download counter
    if [ $? -eq 0 ]; then
        ((download_counter++))
    fi
done

# Print a summary of how many files were downloaded vs total
echo "downloaded $download_counter of ${#urlArray[@]} files to $savedir"



