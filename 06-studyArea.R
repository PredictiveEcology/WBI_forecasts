do.call(setPaths, preamblePaths)

source("05-google-ids.R")
newGoogleIDs <- gdriveSims[["simOutPreamble"]] == ""

preambleObjects <- list()

preambleParams <- list(
  WBI_dataPrep_studyArea = list(
    ".useCache" = TRUE,
    "climateGCM" = climateGCM,
    "climateSSP" = climateSSP,
    "historicalFireYears" = 1991:2020,
    "studyAreaName" = studyAreaName
  )
)

fsimOutPreamble <- simFile(paste0("simOutPreamble_", studyAreaName, "_", climateGCM, "_", climateSSP), Paths$outputPath, ext = "qs")
if (isTRUE(usePrerun)) {
  if (!file.exists(fsimOutPreamble)) {
    googledrive::drive_download(file = as_id(gdriveSims[["simOutPreamble"]]), path = fsimOutPreamble)
  }
  simOutPreamble <- loadSimList(fsimOutPreamble)
} else {
  simOutPreamble <- Cache(simInitAndSpades,
                          times = list(start = 0, end = 1),
                          params = preambleParams,
                          modules = c("WBI_dataPrep_studyArea"),
                          objects = preambleObjects,
                          paths = preamblePaths,
                          #useCache = "overwrite",
                          #useCloud = useCloudCache,
                          #cloudFolderID = cloudCacheFolderID,
                          userTags = c("WBI_dataPrep_studyArea", studyAreaName)
  )

  saveSimList(
    sim = simOutPreamble,
    filename = fsimOutPreamble,
    #filebackedDir = dsimOutPreamble,
    fileBackend = 2 ## 0 = no change; 1 = copy rasters to fileBackedDir; 2 = rasters to memory
  )

  if (isTRUE(reupload)) {
    if (isTRUE(newGoogleIDs)) {
      googledrive::drive_put(media = fsimOutPreamble, path = gdriveURL, name = basename(fsimOutPreamble), verbose = TRUE)
    } else {
      googledrive::drive_update(file = as_id(gdriveSims[["simOutPreamble"]]), media = fsimOutPreamble)
    }
  }
}

nSpecies <- length(unique(simOutPreamble$sppEquiv$LandR))
