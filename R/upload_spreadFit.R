Require::Require("reproducible")
Require::Require("googledrive")

source("05-google-ids.R")

try(file.move(
  file.path("outputs", studyAreaName, "figures", "spreadFit_coeffs.png"),
  file.path("outputs", studyAreaName, "figures", sprintf("spreadFit_coeffs_%s_run_%02d.png", studyAreaName, run))
))

filesToUpload <- c(
  sprintf("fireSense_SpreadFit_veg_coeffs_%s.txt", studyAreaName),
  paste0("figures/PCAcoeffLoadings_", studyAreaName, ".png")
)

gid_results <- gdriveSims[studyArea == studyAreaName & simObject == "results", gid]
lapply(filesToUpload, function(f) {
  retry(quote(drive_put(file.path("outputs", studyAreaName, f), unique(as_id(gid_results)))),
        retries = 5, exponentialDecayBase = 2)
})
