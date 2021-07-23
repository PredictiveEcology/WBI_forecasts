Require::Require("reproducible")
Require::Require("googledrive")

source("05-google-ids.R")

filesToUpload <- c(
  paste0("fireSense_SpreadFit_veg_coeffs_", studyAreaName, ".txt"),
  paste0("figures/PCAcoeffLoadings_", studyAreaName, ".png"),
  paste0("figures/spreadFit_coeffs_", studyAreaName, ".png")
)

lapply(filesToUpload, function(f) {
  retry(drive_upload(file.path("outputs", studyAreaName, f), as_id(gdriveSims[["results"]]), overwrite = TRUE),
        retries = 5, exponentialDecayBase = 2)
})
