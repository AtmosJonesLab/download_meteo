#!/bin/bash

start_date='2024-10-07'   # YYYY-MM-DD
end_date='2025-07-30'     # YYYY-MM-DD (inclusive)
meteo_type="gdal"         # Options: 'hrrr', 'nam12', 'gfs0p25'

echo "$start_date"
echo "$end_date"

get_week_of_month() {
    local input_date="${1:-$(date +%Y-%m-%d)}"

    # Day of the month (1-31)
    local day
    day=$(date -d "$input_date" +%-d)

    # Day of the week for the 1st of that month (0=Sunday..6=Saturday)
    local first_of_month
    first_of_month=$(date -d "$(date -d "$input_date" +%Y-%m-01)" +%w)

    # Week of the month (1-based)
    local week_of_month=$(( (day + first_of_month - 1) / 7 + 1 ))

    echo "$week_of_month"
}

tmp_date=$start_date
tmp_week=$(( $(date -d "$tmp_date" +%s) / 604800 ))
end_week=$(( $(date -d "$end_date" +%s) / 604800 ))

while [[ $tmp_week -le $end_week ]]; do
    day=$(date -d "$tmp_date" +%-d)

    e_date=$(date -d "$tmp_date" "+%b%y")
    echo "$tmp_week $tmp_date ${e_date,,}-w$(get_week_of_month $tmp_date)"
    tmp_date=$(date --date "$tmp_date + 1 week" +"%Y-%m-%d")
    tmp_week=$(( $(date -d "$tmp_date" +%s) / 604800 ))
done



#s_date=$(date -d "$start_date" "+%b%y")
#e_date=$(date -d "$end_date" "+%b%y")
#
#echo "gdas1-${s_date,,}-$(get_week_of_month $start_date)"
#echo "gdas1-${e_date,,}-$(get_week_of_month $end_date)"




