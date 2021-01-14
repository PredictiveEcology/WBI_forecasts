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

biomassMaps2001 <- Cache(simInitAndSpades,
                         times = list(start = 2001, end = 2001),
                         params = dataPrepParams2001,
                         modules = list("Biomass_speciesData", "Biomass_borealDataPrep"), ## TODO: separate to use different caches
                         objects = dataPrepObjects,
                         paths = getPaths(),
                         loadOrder = c("Biomass_speciesData", "Biomass_borealDataPrep"),
                         outputs = dataPrepOutputs2001,
                         useCloud = useCloudCache,
                         cloudFolderID = cloudCacheFolderID,
                         userTags = c("dataPrep2001", studyAreaName))

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

biomassMaps2011 <- Cache(simInitAndSpades,
                         times = list(start = 2011, end = 2011),
                         params = dataPrepParams2011,
                         modules = list("Biomass_speciesData", "Biomass_borealDataPrep"),
                         objects = dataPrepObjects2011,
                         paths = getPaths(),
                         loadOrder = c("Biomass_speciesData", "Biomass_borealDataPrep"),
                         clearSimEnv = TRUE,
                         outputs = dataPrepOutputs2011,
                         useCloud = useCloudCache,
                         cloudFolderID = cloudCacheFolderID,
                         userTags = c("dataPrep2011", studyAreaName))

rm(dataPrepOutputs2011, dataPrepParams2011, dataPrepOutputs2001, dataPrepParams2001)

fSdataPrepParams <- list(
  "fireSense_dataPrepFit" = list(
    ".studyAreaName" = studyAreaName,
    "fireYears" = 2001:2019, #this will be fixed to post kNN only
    "sppEquivCol" = simOutPreamble$sppEquivCol,
    "useCentroids" = TRUE,
    "whichModulesToPrepare" = c("fireSense_SpreadFit") ## TODO: run for escape too , "fireSense_IgnitionFit"
  )
)

simOutPreamble$rasterToMatch <- mask(simOutPreamble$rasterToMatch, simOutPreamble$studyArea)
fSdataPrepObjects <- list(
  "cohortData2001" = biomassMaps2001$cohortData,
  "cohortData2011" = biomassMaps2011$cohortData,
  "historicalClimateRasters" = simOutPreamble$historicalClimateRasters,
  "pixelGroupMap2001" = biomassMaps2001$pixelGroupMap,
  "pixelGroupMap2011" = biomassMaps2011$pixelGroupMap,
  "rasterToMatch" = simOutPreamble$rasterToMatch, #this needs to be masked
  "rstLCC" = biomassMaps2001$rstLCC,
  "sppEquiv" = simOutPreamble$sppEquiv,
  "standAgeMap2001" = biomassMaps2001$standAgeMap,
  "standAgeMap2011" = biomassMaps2011$standAgeMap,
  "studyArea" = simOutPreamble$studyArea
)

# rm(biomassMaps2011, biomassMaps2001) #no need to keep except during development
amc::.gc()
simDataPrep <- Cache(
  simInitAndSpades,
  times =  list(start = 2011, end = 2011),
  params = fSdataPrepParams,
  objects = fSdataPrepObjects,
  paths = dataPrepPaths,
  modules = "fireSense_dataPrepFit",
  userTags = c("fireSense_dataPrepFit", studyAreaName)
)
# rm(biomassMaps2001, biomassMaps2011) ## TODO: don't uncomment this until this works 100%
