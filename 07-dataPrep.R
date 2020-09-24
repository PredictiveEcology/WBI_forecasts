#this script will run Biomass_borealDataPrep + Biomass_speciesData twice, to generate some objects for fitting
do.call(setPaths, dataPrepPaths)

dataPrepParams2001 <- list(
  Biomass_borealDataPrep = list(
    "sppEquivCol" = simOutPreamble$sppEquivCol,
    "successionTimeStep" = dataPrep$successionTimeStep,
    "pixelGroupAgeClass" = dataPrep$pixelGroupAgeClass,
    ".useCache" = c(".inputObjects", "init"),
    ".useCache" = dataPrep$useCache,
    "subsetDataBiomassModel" = subsetDataBiomassModel,
    "exportModels" = "all",
    '.studyAreaName' = paste0(studyAreaName, 2001)
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
                                  file = c("cohortData2001_fireSense.rds",
                                           "pixelGroupMap2001_fireSense.rds",
                                           "speciesLayers2001_fireSense.rds",
                                           "standAgeMap2001_borealDataPrep.rds",
                                           "rawBiomassMap2001_borealDataPrep.rds"))

dataPrepObjects <- list(studyArea = simOutPreamble$studyArea,
                        rasterToMatch = simOutPreamble$rasterToMatch,
                        rasterToMatchLarge = simOutPreamble$rasterToMatchLarge,
                        studyAreaLarge = simOutPreamble$studyAreaLarge,
                        sppEquiv = simOutPreamble$sppEquiv,
                        sppColorVect = sppColorVect)


biomassMaps2001 <- simInitAndSpades(times = list(start = 2001, end = 2001),
                                    params = dataPrepParams2001,
                                    modules = list("Biomass_speciesData", "Biomass_borealDataPrep"),
                                    objects = objects,
                                    paths = getPaths(),
                                    loadOrder = c("Biomass_speciesData", "Biomass_borealDataPrep"),
                                    outputs = dataPrepOutputs2001,
                                    userTags = c("dataPrep2001"))

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


biomassMaps2011 <- simInitAndSpades(times = list(start = 2011, end = 2011),
                                    params = dataPrepParams2011,
                                    modules = list("Biomass_speciesData", "Biomass_borealDataPrep"),
                                    objects = objects,
                                    paths = getPaths(),
                                    loadOrder = c("Biomass_speciesData", "Biomass_borealDataPrep"),
                                    clearSimEnv = TRUE,
                                    outputs = dataPrepOutputs2011,
                                    userTags = c("objective:preambleBiomassDataPrep",
                                                 "time:year2011"))

rm(dataPrepOutputs2011, dataPrepParams2011, dataPrepOutputs2001, dataPrepParams2001)
