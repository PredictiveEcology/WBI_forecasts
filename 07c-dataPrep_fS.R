## NOTE: 07a-dataPrep_2001.R and 07b-dataPrep_2011.R need to be run before this script

source("05-prerun.R")
newGoogleIDs <- gdriveSims[["fSsimDataPrep"]] == ""

fSdataPrepParams <- list(
  "fireSense_dataPrepFit" = list(
    ".studyAreaName" = studyAreaName,
    "fireYears" = 2001:2019, # this will be fixed to post kNN only
    "sppEquivCol" = simOutPreamble$sppEquivCol,
    "useCentroids" = TRUE,
    ".useCache" = ".inputObjects",
    "whichModulesToPrepare" = c("fireSense_IgnitionFit", "fireSense_EscapeFit", "fireSense_SpreadFit")
  )
)

simOutPreamble$rasterToMatch <- raster::mask(simOutPreamble$rasterToMatch, simOutPreamble$studyArea)
fSdataPrepObjects <- list(
  "cohortData2001" = biomassMaps2001[["cohortData"]],
  "cohortData2011" = biomassMaps2011[["cohortData"]],
  "historicalClimateRasters" = simOutPreamble[["historicalClimateRasters"]],
  "pixelGroupMap2001" = biomassMaps2001[["pixelGroupMap"]],
  "pixelGroupMap2011" = biomassMaps2011[["pixelGroupMap"]],
  "rasterToMatch" = simOutPreamble[["rasterToMatch"]], #this needs to be masked
  "rstLCC" = biomassMaps2001[["rstLCC"]],
  "sppEquiv" = simOutPreamble[["sppEquiv"]],
  "standAgeMap2001" = biomassMaps2001[["standAgeMap"]],
  "standAgeMap2011" = biomassMaps2011[["standAgeMap"]],
  "studyArea" = simOutPreamble[["studyArea"]]
)

invisible(replicate(10, gc()))

#dfSsimDataPrep <- file.path(Paths$outputPath, paste0("fSsimDataPrep_", studyAreaName)) %>%
#  checkPath(create = TRUE)
#afSsimDataPrep <- paste0(dfSsimDataPrep, ".7z")
ffSsimDataPrep <- file.path(Paths$outputPath, paste0("fSsimDataPrep_", studyAreaName, ".qs"))
if (isTRUE(usePrerun)) {
  if (!file.exists(ffSsimDataPrep)) {
    googledrive::drive_download(file = as_id(gdriveSims[["fSsimDataPrep"]]), path = ffSsimDataPrep)
  }
  #if (!dir.exists(dfSsimDataPrep) || length(list.files(dfSsimDataPrep)) == 0) {
  #  googledrive::drive_download(file = as_id(gdriveSims[["fSsimDataPrepArchive"]]), path = afSsimDataPrep)
  #  archive::archive_extract(basename(afSsimDataPrep), dirname(afSsimDataPrep))
  #}
  fSsimDataPrep <- loadSimList(ffSsimDataPrep)
} else {
  fSsimDataPrep <- Cache(
    simInitAndSpades,
    times =  list(start = 2011, end = 2011),
    params = fSdataPrepParams,
    objects = fSdataPrepObjects,
    paths = dataPrepPaths,
    modules = "fireSense_dataPrepFit",
    .plots = NA,
    #useCloud = useCloudCache,
    #cloudFolderID = cloudCacheFolderID,
    userTags = c("fireSense_dataPrepFit", studyAreaName)
  )
  saveSimList(
    sim = fSsimDataPrep,
    filename = ffSsimDataPrep,
    #filebackedDir = dfSsimDataPrep,
    fileBackend = 2
  )
  #archive::archive_write_dir(archive = afSsimDataPrep, dir = dfSsimDataPrep)
  if (isTRUE(firstRun)) {
    googledrive::drive_put(media = ffSsimDataPrep, path = gdriveURL, name = basename(ffSsimDataPrep), verbose = TRUE)
    #googledrive::drive_put(media = afSsimDataPrep, path = gdriveURL, name = basename(afSsimDataPrep), verbose = TRUE)
  } else {
    googledrive::drive_update(file = as_id(gdriveSims[["fSsimDataPrep"]]), media = ffSsimDataPrep)
    #googledrive::drive_update(file = as_id(gdriveSims[["fSsimDataPrepArchive"]]), media = afSsimDataPrep)
  }
}
