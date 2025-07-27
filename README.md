# 🌦 NOAA Meteorological Data Downloader

This repository includes both **Bash** and **R** scripts to automate downloading meteorological data files from NOAA's [READY archive](https://www.ready.noaa.gov/), with optional integration into a **Google Cloud Storage (GCS)** bucket for the R version.

---

## 📁 Supported Meteorological Products

All scripts support the following products:

| Product   | Description                                       |
| --------- | ------------------------------------------------- |
| `nam12`   | North American Mesoscale Model (12 km resolution) |
| `gfs0p25` | Global Forecast System (0.25° resolution)         |
| `hrrr`    | High-Resolution Rapid Refresh (3 km resolution)   |

---

## 🧪 Scripts

### ✅ Bash Version

This version supports downloading for range of dates, skipping files already downloaded.

```bash
# download_meteo.sh
start_date='2024-10-07'   # YYYY-MM-DD
end_date='2024-10-07'     # YYYY-MM-DD (inclusive)
meteo_type="nam12"         # Options: 'hrrr', 'nam12', 'gfs0p25'
savedir="/tmp"            # Local directory to save files
```

#### 🔧 Usage

Make the script executable and run it:

```bash
chmod +x download_meteo.sh
./download_meteo.sh
```

A simplified example for one day and one product is provided in `mwe_download_meteo.sh`.

---

### ✅ R Version

The script will:

* Parse the datetime and determine the relevant file(s)
* Check for existing files locally
* Optionally check a **GCS bucket** for the file
* Download from NOAA if needed
* Upload newly fetched files back to GCS


```r
# R download setup
datetime_of_interest <- "2024-06-30 12:24:00"
met_product <- "nam12"         # "nam12", "gfs0p25", "hrrr"
full_day_hrrr <- TRUE         # If TRUE and product == "hrrr", get all 4 chunks
met_folder <- "~/meteo"       # Local directory for downloads

# Optional GCS integration
bucket_folder <- "gs://gu-gsas-pi-tj302" # private GU bucket.
check_bucket_folder <- TRUE   # enable storage in bucket
```


#### 🔧 Usage

Executable script using `Rscript`:

```bash
Rscript ./download_meteo.r
```

---

## ☁️ GCS Bucket Logic (R Only)

When `check_bucket_folder = TRUE`, the R script:

1. Attempts to copy the file from GCS using `gsutil`.
2. Falls back to downloading from NOAA if the file is not found.
3. Uploads new files to GCS if they were downloaded from NOAA.

### 🧰 GCS Setup

To enable this:

* Authenticate with GCP (`gcloud auth login`)
* Ensure the GCS bucket exists and is writable
* Have [`gsutil`](https://cloud.google.com/storage/docs/gsutil) installed and in your PATH

---