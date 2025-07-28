# Set the datetime of interest (used to determine which met file(s) to fetch)
datetime_of_interest <- "2022-06-14 16:00:00"
# Local folder where meteorological data will be stored
met_folder <- "~/meteo"

# Set the meteorological product: 'nam12', 'gfs0p25', or 'hrrr'
met_product <- "hrrr"
# For met_product='hrrr' only: if TRUE, download all 4x 6-hour chunks
full_day_hrrr <- TRUE

# Enable checking of Google Cloud Storage (GCS) bucket for existing files
bucket_folder <- "gs://gu-gsas-pi-tj302" # GU private bucket.
check_bucket_folder <- TRUE # set FALSE if no access to GU private bucket

# Convert the datetime string to POSIXlt for date/time manipulation
datetime_of_interest <- strptime(datetime_of_interest, format = "%Y-%m-%d %H:%M:%S")

# Format the date into "YYYYMMDD" string for use in URLs and filenames
dt_string <- strftime(datetime_of_interest, format = "%Y%m%d")

# Initialize lists to store URLs and filenames
urlArray <- c()

if (met_product == "nam12") {
    local_folder <- file.path(met_folder, "NAM")
    bucket_met_folder <- file.path(bucket_folder, "meteo", "NAM")

    # Construct NAM URL
    urlArray <- c(urlArray, sprintf("https://www.ready.noaa.gov/data/archives/nam12/%s_nam12", dt_string))

} else if (met_product == "gfs0p25") {
    local_folder <- file.path(met_folder, "GFS")
    bucket_met_folder <- file.path(bucket_folder, "meteo", "GFS")

    urlArray <- c(urlArray, sprintf("https://www.ready.noaa.gov/data/archives/gfs0p25/%s_gfs0p25", dt_string))

} else if (met_product == "hrrr") {
    # increase timout for larger files
    options(timeout=300)

    local_folder <- file.path(met_folder, "HRRR")
    bucket_met_folder <- file.path(bucket_folder, "meteo", "HRRR")

    # Determine hour of day from datetime_of_interest
    hour_of_interest <- as.integer(strftime(datetime_of_interest, format = "%H"))

    # Add relevant HRRR 6-hour chunks, or all if full_day_hrrr is TRUE
    if (((hour_of_interest >= 0) && (hour_of_interest < 6)) || full_day_hrrr) {
        urlArray <- c(urlArray, sprintf("https://www.ready.noaa.gov/data/archives/hrrr/%s_00-05_hrrr", dt_string))
    }
    if (((hour_of_interest >= 6) && (hour_of_interest < 12)) || full_day_hrrr) {
        urlArray <- c(urlArray, sprintf("https://www.ready.noaa.gov/data/archives/hrrr/%s_06-11_hrrr", dt_string))
    }
    if (((hour_of_interest >= 12) && (hour_of_interest < 18)) || full_day_hrrr) {
        urlArray <- c(urlArray, sprintf("https://www.ready.noaa.gov/data/archives/hrrr/%s_12-17_hrrr", dt_string))
    }
    if (((hour_of_interest >= 18) && (hour_of_interest < 24)) || full_day_hrrr) {
        urlArray <- c(urlArray, sprintf("https://www.ready.noaa.gov/data/archives/hrrr/%s_18-23_hrrr", dt_string))
    }

} else {
    stop(sprintf("meteo file type '%s' is not registered", met_product))
}

# Create local directory if it doesn't exist
if (!dir.exists(local_folder)) {
    message(sprintf("creating directory '%s'...", local_folder))
    dir.create(local_folder, recursive = TRUE)
}

# Define base gsutil command with performance optimization
gsutil_string <- "gsutil -o GSUtil:parallel_composite_upload_threshold=150M"

# Loop through all URLs to manage local and bucket storage
for (url in urlArray) {
    LOCAL_FOUND <- FALSE  # Flag if file exists locally
    BUCKET_FOUND <- FALSE # Flag if file exists in the GCS bucket

    filename <- basename(url)  # Extract filename from URL
    if (met_product == 'hrrr') {
        ssplit <- strsplit(filename, "_")[[1]]
        filename <- paste(ssplit[1], substr(ssplit[2], 1, 2), ssplit[3], sep="_")
    }

    # Full local path and GCS bucket path
    local_filename  <- file.path(local_folder, filename)
    bucket_filename <- file.path(bucket_met_folder, filename)

    message(sprintf("verifying '%s'...", local_filename))

    # Check if file already exists locally
    LOCAL_FOUND <- file.exists(local_filename)

    # Try downloading file from bucket if enabled
    if (check_bucket_folder) {
        if (!LOCAL_FOUND) {
            out <- system(paste(gsutil_string, "cp", bucket_filename, local_filename))
        } else {
            out <- system(paste("gsutil", "-q stat", bucket_filename))
        }
        if (out == 0) {
            BUCKET_FOUND <<- TRUE
        }
        LOCAL_FOUND <- file.exists(local_filename)  # double-check local existence
    }

    # If not found locally or in the bucket, download from NOAA directly
    if (!LOCAL_FOUND) {
        download.file(url, local_filename)
        LOCAL_FOUND <- file.exists(local_filename)
    }

    # Warn if the download failed
    if (!LOCAL_FOUND) {
        warning(sprintf("failed to download '%s'", url))
    }

    # Upload the file to the bucket if it was newly downloaded and not already in the bucket
    if (LOCAL_FOUND && (!BUCKET_FOUND && check_bucket_folder)) {
        out <- system(paste(gsutil_string, "cp", local_filename, bucket_filename))
        if (out == 0) {
            BUCKET_FOUND <<- TRUE
        }
    }
}
