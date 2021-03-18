#this script will run Biomass_borealDataPrep + Biomass_speciesData twice, to generate some objects for fitting
do.call(setPaths, dataPrepPaths)

dataPrep <- list(
  subsetDataBiomassModel = 50,
  pixelGroupAgeClass = 20,
  successionTimeStep = 10,
  useCache = TRUE
)

dataPrepParams2001 <- list(
  Biomass_borealDataPrep = list(
    # "biomassModel" = quote(lme4::lmer(B ~ logAge * speciesCode + cover * speciesCode + (1 | ecoregionGroup))),
    "biomassModel" = quote(lme4::lmer(B ~ logAge * speciesCode + cover * speciesCode +
                                        (logAge + cover | ecoregionGroup))),
    "ecoregionLayerField" = "ECOREGION", # "ECODISTRIC"
    "exportModels" = "all",
    "forestedLCCClasses" = c(1:15, 20, 32, 34:36),
    "LCCClassesToReplaceNN" = 34:35,
    "pixelGroupAgeClass" = dataPrep$pixelGroupAgeClass,
    "speciesUpdateFunction" = list(
      quote(LandR::speciesTableUpdate(sim$species, sim$speciesTable, sim$sppEquiv, P(sim)$sppEquivCol)),
      quote(LandR::updateSpeciesTable(sim$species, sim$speciesParams))
    ),
    "sppEquivCol" = simOutPreamble$sppEquivCol,
    "subsetDataBiomassModel" = dataPrep$subsetDataBiomassModel,
    "useCloudCacheForStats" = useCloudCache,
    ".studyAreaName" = paste0(studyAreaName, 2001),
    ".useCache" = c(".inputObjects", "init")
  ),
  Biomass_speciesData = list(
    "sppEquivCol" = simOutPreamble$sppEquivCol,
    ".studyAreaName" = paste0(studyAreaName, 2001)
  )
)

dataPrepOutputs2001 <- data.frame(
  objectName = c("cohortData",
                 "pixelGroupMap",
                 "speciesLayers",
                 "standAgeMap",
                 "rawBiomassMap"),
  saveTime = 2001,
  file = paste0(studyAreaName, "_",
                c("cohortData2001_fireSense.rds",
                  "pixelGroupMap2001_fireSense.rds",
                  "speciesLayers2001_fireSense.rds",
                  "standAgeMap2001_borealDataPrep.rds",
                  "rawBiomassMap2001_borealDataPrep.rds"))
)

dataPrepObjects <- list("rasterToMatch" = simOutPreamble$rasterToMatch,
                        "rasterToMatchLarge" = simOutPreamble$rasterToMatchLarge,
                        "sppColorVect" = simOutPreamble$sppColorVect,
                        "sppEquiv" = simOutPreamble$sppEquiv,
                        "studyArea" = simOutPreamble$studyArea,
                        "studyAreaLarge" = simOutPreamble$studyAreaLarge,
                        "studyAreaReporting" = simOutPreamble$studyAreaReporting)

dbiomassMaps2001 <- file.path(Paths$outputPath, paste0("biomassMaps2001_", studyAreaName)) %>%
  checkPath(create = TRUE)
abiomassMaps2001 <- paste0(dbiomassMaps2001, ".7z")
fbiomassMaps2001 <- file.path(Paths$outputPath, paste0("biomassMaps2001_", studyAreaName, ".qs"))
if (isTRUE(usePrerun)) {
  if (!file.exists(fbiomassMaps2001)) {
    googledrive::drive_download(file = as_id(gdriveSims[["biomassMaps2001"]]), path = fbiomassMaps2001)
  }
  if (!dir.exists(dbiomassMaps2001) || length(list.files(dbiomassMaps2001)) == 0) {
    googledrive::drive_download(file = as_id(gdriveSims[["biomassMaps2001Archive"]]), path = abiomassMaps2001)
    archive::archive_extract(basename(abiomassMaps2001), dirname(abiomassMaps2001))
  }
  biomassMaps2001 <- loadSimList(fbiomassMaps2001)
} else {
  biomassMaps2001 <- Cache(
    simInitAndSpades,
    times = list(start = 2001, end = 2001),
    params = dataPrepParams2001,
    modules = list("Biomass_speciesData", "Biomass_borealDataPrep"), ## TODO: separate to use different caches
    objects = dataPrepObjects,
    paths = getPaths(),
    loadOrder = c("Biomass_speciesData", "Biomass_borealDataPrep"),
    # outputs = dataPrepOutputs2001,
    .plots = NA,
    useCloud = useCloudCache,
    cloudFolderID = cloudCacheFolderID,
    userTags = c("dataPrep2001", studyAreaName)
  )
  saveSimList(sim = biomassMaps2001, filename = fbiomassMaps2001, filebackedDir = dbiomassMaps2001, fileBackend = 1)
  archive::archive_write_dir(archive = abiomassMaps2001, dir = dbiomassMaps2001)
  if (isTRUE(firstRun)) {
    googledrive::drive_put(media = fbiomassMaps2001, path = gdriveURL, name = basename(fbiomassMaps2001), verbose = TRUE)
    googledrive::drive_put(media = abiomassMaps2001, path = gdriveURL, name = basename(abiomassMaps2001), verbose = TRUE)
  } else {
    googledrive::drive_update(file = as_id(gdriveSims[["biomassMaps2001"]]), media = fbiomassMaps2001)
    googledrive::drive_update(file = as_id(gdriveSims[["biomassMaps2001Archive"]]), media = abiomassMaps2001)
  }
}

dataPrepParams2011 <- dataPrepParams2001
dataPrepParams2011$Biomass_speciesData$types <- "KNN2011"
dataPrepParams2011$Biomass_speciesData$.studyAreaName <- paste0(studyAreaName, 2011)
dataPrepParams2011$Biomass_borealDataPrep$.studyAreaName <- paste0(studyAreaName, 2011)

dataPrepOutputs2011 <- data.frame(
  objectName = c("cohortData",
                 "pixelGroupMap",
                 "speciesLayers",
                 "standAgeMap",
                 "rawBiomassMap"),
  saveTime = 2011,
  file = c("cohortData2011_fireSense.rds",
           "pixelGroupMap2011_fireSense.rds",
           "speciesLayers2011_fireSense.rds",
           "standAgeMap2011_borealDataPrep.rds",
           "rawBiomassMap2011_borealDataPrep.rds") # Currently not needed
)

dataPrepObjects2011 <- dataPrepObjects
dataPrepObjects2011$standAgeMap <- simOutPreamble$standAgeMap2011

dbiomassMaps2011 <- file.path(Paths$outputPath, paste0("biomassMaps2011_", studyAreaName)) %>%
  checkPath(create = TRUE)
abiomassMaps2011 <- paste0(dbiomassMaps2011, ".7z")
fbiomassMaps2011 <- file.path(Paths$outputPath, paste0("biomassMaps2011_", studyAreaName, ".qs"))
if (isTRUE(usePrerun)) {
  if (!file.exists(fbiomassMaps2011)) {
    googledrive::drive_download(file = as_id(gdriveSims[["biomassMaps2011"]]), path = fbiomassMaps2011)
  }
  if (!dir.exists(dbiomassMaps2011) || length(list.files(dbiomassMaps2011)) == 0) {
    googledrive::drive_download(file = as_id(gdriveSims[["biomassMaps2011Archive"]]), path = abiomassMaps2011)
    archive::archive_extract(basename(abiomassMaps2011), dirname(abiomassMaps2011))
  }
  biomassMaps2011 <- loadSimList(fbiomassMaps2011)
} else {
  biomassMaps2011 <- Cache(
    simInitAndSpades,
    times = list(start = 2011, end = 2011),
    params = dataPrepParams2011,
    modules = list("Biomass_speciesData", "Biomass_borealDataPrep"),
    objects = dataPrepObjects2011,
    paths = getPaths(),
    loadOrder = c("Biomass_speciesData", "Biomass_borealDataPrep"),
    clearSimEnv = TRUE,
    # outputs = dataPrepOutputs2011,
    .plots = "png",
    useCloud = useCloudCache,
    cloudFolderID = cloudCacheFolderID,
    userTags = c("dataPrep2011", studyAreaName)
  )
  saveSimList(sim = biomassMaps2011, filename = fbiomassMaps2011, filebackedDir = dbiomassMaps2011, fileBackend = 1)
  archive::archive_write_dir(archive = abiomassMaps2011, dir = dbiomassMaps2011)
  if (isTRUE(firstRun)) {
    googledrive::drive_put(media = fbiomassMaps2011, path = gdriveURL, name = basename(fbiomassMaps2011), verbose = TRUE)
    googledrive::drive_put(media = abiomassMaps2011, path = gdriveURL, name = basename(abiomassMaps2011), verbose = TRUE)
  } else {
    googledrive::drive_update(file = as_id(gdriveSims[["biomassMaps2011"]]), media = fbiomassMaps2011)
    googledrive::drive_update(file = as_id(gdriveSims[["biomassMaps2011Archive"]]), media = abiomassMaps2011)
  }
}

rm(dataPrepOutputs2011, dataPrepParams2011, dataPrepOutputs2001, dataPrepParams2001)

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

dfSsimDataPrep <- file.path(Paths$outputPath, paste0("fSsimDataPrep_", studyAreaName)) %>%
  checkPath(create = TRUE)
afSsimDataPrep <- paste0(dfSsimDataPrep, ".7z")
ffSsimDataPrep <- file.path(Paths$outputPath, paste0("fSsimDataPrep_", studyAreaName, ".qs"))
if (isTRUE(usePrerun)) {
  if (!file.exists(ffSsimDataPrep)) {
    googledrive::drive_download(file = as_id(gdriveSims[["fSsimDataPrep"]]), path = ffSsimDataPrep)
  }
  if (!dir.exists(dfSsimDataPrep) || length(list.files(dfSsimDataPrep)) == 0) {
    googledrive::drive_download(file = as_id(gdriveSims[["fSsimDataPrepArchive"]]), path = afSsimDataPrep)
    archive::archive_extract(basename(afSsimDataPrep), dirname(afSsimDataPrep))
  }
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
  saveSimList(sim = fSsimDataPrep, filename = ffSsimDataPrep, filebackedDir = dfSsimDataPrep, fileBackend = 1)
  archive::archive_write_dir(archive = afSsimDataPrep, dir = dfSsimDataPrep)
  if (isTRUE(firstRun)) {
    googledrive::drive_put(media = ffSsimDataPrep, path = gdriveURL, name = basename(ffSsimDataPrep), verbose = TRUE)
    googledrive::drive_put(media = afSsimDataPrep, path = gdriveURL, name = basename(afSsimDataPrep), verbose = TRUE)
  } else {
    googledrive::drive_update(file = as_id(gdriveSims[["fSsimDataPrep"]]), media = ffSsimDataPrep)
    googledrive::drive_update(file = as_id(gdriveSims[["fSsimDataPrepArchive"]]), media = afSsimDataPrep)
  }
}
