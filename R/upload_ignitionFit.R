Require::Require("reproducible")
Require::Require("googledrive")

source("05-google-ids.R")

file.move(
  file.path("outputs", studyAreaName, "figures", "ignitionNoFiresFitted.png"),
  file.path("outputs", studyAreaName, "figures", paste0("ignitionNoFiresFitted_", studyAreaName, ".png"))
)

file.move(
  file.path("outputs", studyAreaName, "figures", "IgnitionRatePer100.png"),
  file.path("outputs", studyAreaName, "figures", paste0("IgnitionRatePer100_", studyAreaName, ".png"))
)

filesToUpload <- c(
  paste0("figures/ignitionNoFiresFitted_", studyAreaName, ".png"),
  paste0("figures/IgnitionRatePer100_", studyAreaName, ".png")
)

lapply(filesToUpload, function(f) {
  retry(quote(drive_upload(file.path("outputs", studyAreaName, f), as_id(gdriveSims[["results"]]), overwrite = TRUE)),
        retries = 5, exponentialDecayBase = 2)
})