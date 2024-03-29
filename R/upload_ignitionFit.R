Require::Require("reproducible")
Require::Require("googledrive")

source("05-google-ids.R")

try(file.move(
  file.path("outputs", studyAreaName, "figures", "ignitionNoFiresFitted.png"),
  file.path("outputs", studyAreaName, "figures", paste0("ignitionNoFiresFitted_", studyAreaName, ".png"))
))

try(file.move(
  file.path("outputs", studyAreaName, "figures", "IgnitionRatePer100.png"),
  file.path("outputs", studyAreaName, "figures", paste0("IgnitionRatePer100_", studyAreaName, ".png"))
))

filesToUpload <- c(
  paste0("figures/ignitionNoFiresFitted_", studyAreaName, ".png"),
  paste0("figures/IgnitionRatePer100_", studyAreaName, ".png")
)

gid_results <- gdriveSims[studyArea == studyAreaName & simObject == "results", gid]
lapply(filesToUpload, function(f) {
  retry(quote(drive_put(file.path("outputs", studyAreaName, f), unique(as_id(gid_results)))),
        retries = 5, exponentialDecayBase = 2)
})
