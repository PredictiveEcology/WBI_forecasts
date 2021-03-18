do.call(setPaths, preamblePaths)

preambleObjects <- list()

preambleParams <- list(
  WBI_dataPrep_studyArea = list(
    ".useCache" = TRUE,
    "historicalFireYears" = 1991:2019,
    "studyAreaName" = studyAreaName
  )
)

dsimOutPreamble <- file.path(Paths$outputPath, paste0("simOutPreamble_", studyAreaName)) %>%
  checkPath(create = TRUE)
asimOutPreamble <- paste0(dsimOutPreamble, ".7z")
fsimOutPreamble <- file.path(Paths$outputPath, paste0("simOutPreamble_", studyAreaName, ".qs"))
if (isTRUE(usePrerun)) {
  if (!file.exists(fsimOutPreamble)) {
    googledrive::drive_download(file = as_id(gdriveSims[["simOutPreamble"]]), path = fsimOutPreamble)
  }
  if (!dir.exists(dsimOutPreamble)) { ## NOTE: this dir is empty as all rasters in memory
    googledrive::drive_download(file = as_id(gdriveSims[["simOutPreambleArchive"]]), path = asimOutPreamble)
    archive::archive_extract(basename(asimOutPreamble), dirname(asimOutPreamble))
  }
  simOutPreamble <- loadSimList(fsimOutPreamble)
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
  saveSimList(sim = simOutPreamble, filename = fsimOutPreamble, filebackedDir = dsimOutPreamble, fileBackend = 1)
  archive::archive_write_dir(archive = asimOutPreamble, dir = dsimOutPreamble)
  if (isTRUE(firstRun)) {
    googledrive::drive_put(media = fsimOutPreamble, path = gdriveURL, name = basename(fsimOutPreamble), verbose = TRUE)
    googledrive::drive_put(media = asimOutPreamble, path = gdriveURL, name = basename(asimOutPreamble), verbose = TRUE)
  } else {
    googledrive::drive_update(file = as_id(gdriveSims[["simOutPreamble"]]), media = fsimOutPreamble)
    googledrive::drive_update(file = as_id(gdriveSims[["simOutPreambleArchive"]]), media = asimOutPreamble)
  }
}
