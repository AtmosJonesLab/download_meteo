#!/bin/bash

start_date='2024-10-07'   # YYYY-MM-DD
end_date='2025-07-30'     # YYYY-MM-DD (inclusive)
meteo_type="gdal"         # Options: 'hrrr', 'nam12', 'gfs0p25'

start_date="${start_date:-$(date +%Y-%m-%d)}"
end_date="${end_date:-$(date +%Y-%m-%d)}"

start_week=$(( $(date -d "$start_date" +%s) / 604800 ))
end_week=$(( $(date -d "$end_date" +%s) / 604800 ))

# Store the starting month to detect when it changes
prev_month=$(date -d "$input_date" +%m)

while [[ $start_week -le $end_week ]]; do

    # Day of the month (1-31)
    day=$(date -d "$start_date" +%-d)

    # Day of the week for the 1st of that month (0=Sunday..6=Saturday)
    first_of_month=$(date -d "$(date -d "$start_date" +%Y-%m-01)" +%w)

    # Calculate week of the month
    week_of_month=$(( (day + first_of_month - 1) / 7 + 1 ))

    # Month as 2-digit string
    curr_month=$(date -d "$start_date" +%m)

    # Short date label (e.g. Oct24)
    e_date=$(date -d "$start_date" "+%b%y")

    # Print output line
    echo "$start_week $start_date ${e_date,,}-w$week_of_month"

    # Advance by 1 week
    start_date=$(date --date "$start_date + 1 week" +"%Y-%m-%d")

    # Check if the month has changed
    next_month=$(date -d "$start_date" +%m)
    if [[ "$next_month" != "$curr_month" ]]; then
        # Set start_date to the 1st of the new month
        start_date=$(date -d "$start_date" +%Y-%m-01)
    fi

    # Recalculate start_week for the new start_date
    start_week=$(( $(date -d "$start_date" +%s) / 604800 ))
done



#s_date=$(date -d "$start_date" "+%b%y")
#e_date=$(date -d "$end_date" "+%b%y")
#
#echo "gdas1-${s_date,,}-$(get_week_of_month $start_date)"
#echo "gdas1-${e_date,,}-$(get_week_of_month $end_date)"




