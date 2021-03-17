do.call(setPaths, preamblePaths)

preambleObjects <- list()

preambleParams <- list(
  WBI_dataPrep_studyArea = list(
    ".useCache" = TRUE,
    "historicalFireYears" = 1991:2019,
    "studyAreaName" = studyAreaName
  )
)

fsim <- file.path(Paths$outputPath, paste0("simOutPreamble_", studyAreaName, ".qs"))
if (isTRUE(usePrerun)) {
  if (!file.exists(fsim)) {
    googledrive::drive_download(file = as_id(gdriveSims[["simOutPreamble"]]), path = fsim)
  }
  simOutPreamble <- loadSimList(fsim)
} else {
  simOutPreamble <- Cache(simInitAndSpades,
                          times = list(start = 0, end = 1),
                          params = preambleParams,
                          modules = c("WBI_dataPrep_studyArea"),
                          objects = preambleObjects,
                          paths = preamblePaths,
                          #useCloud = useCloudCache,
                          #cloudFolderID = cloudCacheFolderID,
                          userTags = c("WBI_dataPrep_studyArea", studyAreaName)
  )
  saveSimList(simOutPreamble, fsim, fileBackend = 2)
  if (isTRUE(firstRun)) {
    googledrive::drive_put(media = fsim, path = gdriveURL, name = basename(fsim), verbose = TRUE)
  } else {
    googledrive::drive_update(file = as_id(gdriveSims[["simOutPreamble"]]), media = fsim)
  }
}
