#this script will run Biomass_borealDataPrep + Biomass_speciesData twice, to generate some objects for fitting
do.call(setPaths, dataPrepPaths)

dataPrepParams2001 <- list(
  Biomass_borealDataPrep = list(
    #"biomassModel" = quote(lme4::lmer(B ~ logAge * speciesCode + cover * speciesCode + (1 | ecoregionGroup))),
    "biomassModel" = quote(lme4::lmer(B ~ logAge * speciesCode + cover * speciesCode +
                                        (logAge + cover + speciesCode | ecoregionGroup))),
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
    "successionTimeStep" = dataPrep$successionTimeStep,
    "useCloudCacheForStats" = useCloudCache,
    '.studyAreaName' = paste0(studyAreaName, 2001),
    ".useCache" = c(".inputObjects", "init")
  ),
  Biomass_speciesData = list(
    'sppEquivCol' = simOutPreamble$sppEquivCol,
    '.studyAreaName' = paste0(studyAreaName, 2001)
  )
)
dataPrepOutputs2001 <- data.frame(objectName = c("cohortData",
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
                                                  "rawBiomassMap2001_borealDataPrep.rds")))

dataPrepObjects <- list('studyArea' = simOutPreamble$studyArea,
                        'rasterToMatch' = simOutPreamble$rasterToMatch,
                        'rasterToMatchLarge' = simOutPreamble$rasterToMatchLarge,
                        'studyAreaLarge' = simOutPreamble$studyAreaLarge,
                        'sppEquiv' = simOutPreamble$sppEquiv,
                        'sppColorVect' = simOutPreamble$sppColorVect)

biomassMaps2001 <- Cache(simInitAndSpades,
                         times = list(start = 2001, end = 2001),
                         params = dataPrepParams2001,
                         modules = list("Biomass_speciesData", "Biomass_borealDataPrep"), ## TODO: separate to use different caches
                         objects = dataPrepObjects,
                         paths = getPaths(),
                         loadOrder = c("Biomass_speciesData", "Biomass_borealDataPrep"),
                         outputs = dataPrepOutputs2001,
                         userTags = c("dataPrep2001", studyAreaName))

dataPrepParams2011 <- dataPrepParams2001
dataPrepParams2011$Biomass_speciesData$types <- 'KNN2011'
dataPrepParams2011$Biomass_speciesData$.studyAreaName <- paste0(studyAreaName, 2011)
dataPrepParams2011$Biomass_borealDataPrep$.studyAreaName <- paste0(studyAreaName, 2011)

dataPrepOutputs2011 <- data.frame(objectName = c("cohortData",
                                                 "pixelGroupMap",
                                                 "speciesLayers",
                                                 "standAgeMap",
                                                 "rawBiomassMap"),
                                  saveTime = 2011,
                                  file = c("cohortData2011_fireSense.rds",
                                           "pixelGroupMap2011_fireSense.rds",
                                           "speciesLayers2011_fireSense.rds",
                                           "standAgeMap2011_borealDataPrep.rds",
                                           "rawBiomassMap2011_borealDataPrep.rds")) # Currently not needed


biomassMaps2011 <- Cache(simInitAndSpades,
                         times = list(start = 2011, end = 2011),
                         params = dataPrepParams2011,
                         modules = list("Biomass_speciesData", "Biomass_borealDataPrep"),
                         objects = dataPrepObjects,
                         paths = getPaths(),
                         loadOrder = c("Biomass_speciesData", "Biomass_borealDataPrep"),
                         clearSimEnv = TRUE,
                         outputs = dataPrepOutputs2011,
                         userTags = c('dataPrep2011', studyAreaName))

rm(dataPrepOutputs2011, dataPrepParams2011, dataPrepOutputs2001, dataPrepParams2001)

#run fireSense_dataPrepFit
dataPrepParams <- list(
  'fireSense_dataPrepFit' = list(
    'whichModulesToPrepare' = 'fireSense_SpreadFit', #for Now
    'useCentroids' = TRUE,
    'fireYears' = 1991:(1990 + nlayers(simOutPreamble$historicalClimateRasters$MDC))
    , '.studyAreaName' = studyAreaName
  )
)


simOutPreamble$rasterToMatch <- mask(simOutPreamble$rasterToMatch, simOutPreamble$studyArea)

dataPrepObjects <- list(
  'studyArea' = simOutPreamble$studyArea,
  'rasterToMatch' = simOutPreamble$rasterToMatch, #this needs to be masked
  'historicalClimateRasters' = simOutPreamble$historicalClimateRasters,
  'pixelGroupMap2011' = biomassMaps2011$pixelGroupMap,
  'cohortData2011' = biomassMaps2011$cohortData,
  'pixelGroupMap2001' = biomassMaps2001$pixelGroupMap,
  'cohortData2001' = biomassMaps2001$cohortData,
  'rstLCC' = biomassMaps2001$rstLCC
)

# rm(biomassMaps2011, biomassMaps2001) #no need to keep except during development
amc::.gc()
simDataPrep <- simInitAndSpades(
  times =  list(start = 2011, end = 2011),
  params = dataPrepParams,
  objects = dataPrepObjects,
  paths = dataPrepPaths,
  modules = 'fireSense_dataPrepFit',
  userTags = c("fireSense_dataPrepFit", studyAreaName)
)
# rm(biomassMaps2001, biomassMaps2011) #Don't do this until this works 100%
