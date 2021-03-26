Require::Require("googledrive")

source("05-google-ids.R")

filesToUpload <- c("fireSense_SpreadFit_veg_coeffs.txt",
                   "figures/PCAcoeffLoadings.png",
                   "figures/spreadFit_coeffs.png")

lapply(filesToUpload, function(f) {
  drive_upload(file.path("outputs", studyAreaName, f), as_id(gdriveSims[["results"]]), overwrite = TRUE)
}) ## TODO: upload first time, update subsequently.
