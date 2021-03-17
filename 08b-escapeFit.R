do.call(setPaths, escapeFitPaths)

escapeFitParams <- list(
  fireSense_EscapeFit = list(
    fireSense_escapeFormula = fSsimDataPrep$fireSense_escapeFormula
  )
)

escapeFitObjects <- list(
  fireSense_escapeCovariates = fSsimDataPrep$fireSense_escapeCovariates
)

fsim <- file.path(Paths$outputPath, paste0("escapeOut_", studyAreaName, ".qs"))
if (isTRUE(usePrerun)) {
  if (!file.exists(fsim)) {
    googledrive::drive_download(file = as_id(gdriveSims[["escapeOut"]]), path = fsim)
  }
  escapeOut <- loadSimList(fsim)
} else {
  escapeOut <- simInitAndSpades(times = list(start = 0, end = 1),
                                # ignitionSim <- simInit(times = list(start = 0, end = 1),
                                params = escapeFitParams,
                                modules = "fireSense_EscapeFit",
                                paths = escapeFitPaths,
                                objects = escapeFitObjects)
  saveSimList(escapeOut, fsim, fileBackend = 2)
  if (isTRUE(firstRun)) {
    googledrive::drive_put(media = fsim, path = gdriveURL, name = basename(fsim), verbose = TRUE)
  } else {
    googledrive::drive_update(file = as_id(gdriveSims[["escapeOut"]]), media = fsim)
  }
}
