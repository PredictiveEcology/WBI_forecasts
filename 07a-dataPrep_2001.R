#this script will run Biomass_borealDataPrep + Biomass_speciesData twice, to generate some objects for fitting
do.call(setPaths, dataPrepPaths)

source("05-google-ids.R")
newGoogleIDs <- gdriveSims[["biomassMaps2001"]] == ""

dataPrep <- list(
  subsetDataBiomassModel = 50,
  pixelGroupAgeClass = 20,
  successionTimeStep = 10,
  useCache = TRUE
)

dataPrepModules <- if (isTRUE(useLandR.CS)) {
  list(
    "Biomass_speciesData",
    "Biomass_borealDataPrep",
    "PSP_Clean",
    "Biomass_speciesParameters"
  )
} else {
  list(
    "Biomass_speciesData",
    "Biomass_borealDataPrep"
  )
}

dataPrepParams2001 <- list(
  .globals = list("dataYear" = 2001),
  Biomass_borealDataPrep = list(
    # "biomassModel" = quote(lme4::lmer(B ~ logAge * speciesCode + cover * speciesCode + (1 | ecoregionGroup))),
    "biomassModel" = quote(lme4::lmer(B ~ logAge * speciesCode + cover * speciesCode +
                                        (logAge + cover | ecoregionGroup))),
    "ecoregionLayerField" = "ECOREGION", # "ECODISTRIC"
    "exportModels" = "all",
    "fixModelBiomass" = TRUE,
    "forestedLCCClasses" = 1:6, ## using LCC2010
    "LCCClassesToReplaceNN" = numeric(0), ## using LCC2010
    "pixelGroupAgeClass" = dataPrep$pixelGroupAgeClass,
    "speciesUpdateFunction" = list(
      quote(LandR::speciesTableUpdate(sim$species, sim$speciesTable, sim$sppEquiv, P(sim)$sppEquivCol)),
      quote(LandR::updateSpeciesTable(sim$species, sim$speciesParams))
    ),
    "sppEquivCol" = simOutPreamble$sppEquivCol,
    "subsetDataBiomassModel" = dataPrep$subsetDataBiomassModel,
    "useCloudCacheForStats" = useCloudCache,
    ".plots" = c("object", "png", "raw"),
    ".studyAreaName" = paste0(studyAreaName, 2001),
    ".useCache" = c(".inputObjects", "init")
  ),
  Biomass_speciesData = list(
    #"dataYear" = 2001, ## passed globally
    "sppEquivCol" = simOutPreamble$sppEquivCol,
    "types" = "KNN",
    ".studyAreaName" = paste0(studyAreaName, 2001)
  ),
  Biomass_speciesParameters = list(
    constrainGrowthCurve = c(0, 1),
    constrainMaxANPP = c(3.0, 3.5),
    constrainMortalityShape = c(10, 25),
    GAMMiterations = 2,
    #GAMMknots[names(GAMMknots) %in% sppEquiv$LandR]
    GAMMknots = 3,
    minimumPlotsPerGamm = 65,
    quantileAgeSubset = 98,
    sppEquivCol = simOutPreamble$sppEquivCol
  )#,
  #PSP_clean = list() ## use defaults for now
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

#dbiomassMaps2001 <- file.path(Paths$outputPath, paste0("biomassMaps2001_", studyAreaName)) %>%
#  checkPath(create = TRUE)
#abiomassMaps2001 <- paste0(dbiomassMaps2001, ".7z")
fbiomassMaps2001 <- file.path(Paths$outputPath, paste0("biomassMaps2001_", studyAreaName, ".qs"))
if (isTRUE(usePrerun)) {
  if (!file.exists(fbiomassMaps2001)) {
    googledrive::drive_download(file = as_id(gdriveSims[["biomassMaps2001"]]), path = fbiomassMaps2001)
  }
  #if (!dir.exists(dbiomassMaps2001) || length(list.files(dbiomassMaps2001)) == 0) {
  #  googledrive::drive_download(file = as_id(gdriveSims[["biomassMaps2001Archive"]]), path = abiomassMaps2001)
  #  archive::archive_extract(basename(abiomassMaps2001), dirname(abiomassMaps2001))
  #}
  biomassMaps2001 <- loadSimList(fbiomassMaps2001)
} else {
  biomassMaps2001 <- Cache(
    simInitAndSpades,
    times = list(start = 2001, end = 2001),
    params = dataPrepParams2001,
    modules = dataPrepModules,
    objects = dataPrepObjects,
    paths = getPaths(),
    loadOrder = unlist(dataPrepModules),
    # outputs = dataPrepOutputs2001,
    .plots = NA,
    useCloud = useCloudCache,
    cloudFolderID = cloudCacheFolderID,
    userTags = c("dataPrep2001", studyAreaName)
  )

  if (isTRUE(reupload)) {
    saveSimList(
      sim = biomassMaps2001,
      filename = fbiomassMaps2001,
      #filebackedDir = dbiomassMaps2001,
      fileBackend = 2
    )
    #archive::archive_write_dir(archive = abiomassMaps2001, dir = dbiomassMaps2001)

    if (isTRUE(newGoogleIDs)) {
      googledrive::drive_put(media = fbiomassMaps2001, path = gdriveURL, name = basename(fbiomassMaps2001), verbose = TRUE)
      #googledrive::drive_put(media = abiomassMaps2001, path = gdriveURL, name = basename(abiomassMaps2001), verbose = TRUE)
    } else {
      googledrive::drive_update(file = as_id(gdriveSims[["biomassMaps2001"]]), media = fbiomassMaps2001)
      #googledrive::drive_update(file = as_id(gdriveSims[["biomassMaps2001Archive"]]), media = abiomassMaps2001)
    }
  }
}
