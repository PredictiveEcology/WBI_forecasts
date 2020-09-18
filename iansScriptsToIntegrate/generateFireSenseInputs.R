
PreambleParameters <- list(
  Biomass_borealDataPrep = list(
    "sppEquivCol" = 'RIA',
    "successionTimestep" = 10,
    "pixelGroupAgeClass" = 20,
    ".useCache" = c(".inputObjects", "init"),
    # ".useCache" = FALSE,
    "subsetDataBiomassModel" = 50,
    "exportModels" = "all",
    '.studyAreaName' = paste0(studyAreaName, 2001)
  ),
  Biomass_speciesData = list(
    'sppEquivCol' = 'RIA', 
    '.studyAreaName' = paste0(studyAreaName, 2001)
  )
)
outputsPreamble2001 <- data.frame(objectName = c("cohortData", 
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

# 1. Run borealBiomassDataPrep ALONE and save: cohortData + pixelGroupMap: will be used
# in fireSense_SizeFit and fireSense_SpreadFit (later on, will be also used in Ignition and Escape fits)
objects <- list(studyArea = studyArea,
                rasterToMatch = rasterToMatch,
                rasterToMatchLarge = rasterToMatchLarge,
                studyAreaLarge = studyAreaLarge,
                sppEquiv = sppEquivalencies_CA,
                sppColorVect = sppColorVect)


biomassMaps2001 <- simInitAndSpades(times = list(start = 2001, end = 2001),
                                    params = PreambleParameters,
                                    modules = list("Biomass_speciesData", "Biomass_borealDataPrep"),
                                    objects = objects,
                                    paths = getPaths(),
                                    loadOrder = c("Biomass_speciesData", "Biomass_borealDataPrep"),
                                    outputs = outputsPreamble2001,
                                    userTags = c("objective:preambleBiomassDataPrep",
                                                 "time:year2001"))


preAmbleParameters2011 <- PreambleParameters
preAmbleParameters2011$Biomass_speciesData$types <- 'KNN2011'
preAmbleParameters2011$Biomass_speciesData$.studyAreaName <- paste0(studyAreaName, 2011)
preAmbleParameters2011$Biomass_borealDataPrep$.studyAreaName <- paste0(studyAreaName, 2011)


outputsPreamble2011 <- data.frame(objectName = c("cohortData", 
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
                                    params = preAmbleParameters2011,
                                    modules = list("Biomass_speciesData", "Biomass_borealDataPrep"),
                                    objects = objects,
                                    paths = getPaths(),
                                    loadOrder = c("Biomass_speciesData", "Biomass_borealDataPrep"),
                                    clearSimEnv = TRUE,
                                    outputs = outputsPreamble2011,
                                    userTags = c("objective:preambleBiomassDataPrep", 
                                                 "time:year2011"))

