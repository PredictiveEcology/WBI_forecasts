## NOTE: 07a-dataPrep_2001.R and 07b-dataPrep_2011.R need to be run before this script

source("05-google-ids.R")
newGoogleIDs <- gdriveSims[["fSsimDataPrep"]] == ""

fSdataPrepParams <- list(
  "fireSense_dataPrepFit" = list(
    ".studyAreaName" = studyAreaName,
    "climateGCM" = climateGCM,
    "climateSSP" = climateSSP,
    "fireYears" = 2001:2020, # this will be fixed to post kNN only
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
  "rstLCC" = biomassMaps2011[["rstLCC"]],
  "sppEquiv" = as.data.table(simOutPreamble[["sppEquiv"]]),
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

  ## TODO: temporary until bug in qs is fixed
  fSsimDataPrep$fireSense_escapeCovariates <- as.data.table(fSsimDataPrep$fireSense_escapeCovariates)
  fSsimDataPrep$fireSense_annualSpreadFitCovariates <- lapply(fSsimDataPrep$fireSense_annualSpreadFitCovariates, as.data.table)
  fSsimDataPrep$fireBufferedListDT <- lapply(fSsimDataPrep$fireBufferedListDT, as.data.table)
  fSsimDataPrep$fireSense_nonAnnualSpreadFitCovariates[[1]] <- as.data.table(fSsimDataPrep$fireSense_nonAnnualSpreadFitCovariates[[1]])
  fSsimDataPrep$fireSense_nonAnnualSpreadFitCovariates[[2]] <- as.data.table(fSsimDataPrep$fireSense_nonAnnualSpreadFitCovariates[[2]])
  fSsimDataPrep$cohortData2011 <- as.data.table(fSsimDataPrep$cohortData2011)
  fSsimDataPrep$cohortData2001 <- as.data.table(fSsimDataPrep$cohortData2001)
  fSsimDataPrep$fireSense_ignitionCovariates <- as.data.table(fSsimDataPrep$fireSense_ignitionCovariates)
  fSsimDataPrep$landcoverDT <- as.data.table(fSsimDataPrep$landcoverDT)
  fSsimDataPrep$terrainDT <- as.data.table(fSsimDataPrep$terrainDT)
  fSsimDataPrep$sppEquiv <- as.data.table(fSsimDataPrep$sppEquiv)
  ## end TODO
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

  if (isTRUE(reupload)) {
    saveSimList(
      sim = fSsimDataPrep,
      filename = ffSsimDataPrep,
      #filebackedDir = dfSsimDataPrep,
      fileBackend = 2
    )
    #archive::archive_write_dir(archive = afSsimDataPrep, dir = dfSsimDataPrep)

    if (isTRUE(newGoogleIDs)) {
      googledrive::drive_put(media = ffSsimDataPrep, path = gdriveURL, name = basename(ffSsimDataPrep), verbose = TRUE)
      #googledrive::drive_put(media = afSsimDataPrep, path = gdriveURL, name = basename(afSsimDataPrep), verbose = TRUE)
    } else {
      googledrive::drive_update(file = as_id(gdriveSims[["fSsimDataPrep"]]), media = ffSsimDataPrep)
      #googledrive::drive_update(file = as_id(gdriveSims[["fSsimDataPrepArchive"]]), media = afSsimDataPrep)
    }
  }
}

stopifnot(packageVersion("fireSenseUtils") >= "0.0.4.9082") ## compareMDC() now in fireSenseUtils
ggMDC <- compareMDC(historicalMDC = simOutPreamble$historicalClimateRasters$MDC,
                    projectedMDC = simOutPreamble$projectedClimateRasters$MDC,
                    flammableRTM = fSsimDataPrep$flammableRTM)
fggMDC <- file.path(dataPrepPaths$outputPath, "figures", paste0("compareMDC_", studyAreaName, "_",
                                                                climateGCM, "_", climateSSP, ".png"))
checkPath(dirname(fggMDC), create = TRUE)

ggsave(plot = ggMDC, filename = fggMDC)

if (isTRUE(firstRunMDCplots)) {
  googledrive::drive_upload(media = fggMDC, path = as_id(gdriveSims[["results"]]), name = basename(fggMDC), overwrite = TRUE)
}
