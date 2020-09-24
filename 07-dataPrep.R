#this script will run Biomass_borealDataPrep + Biomass_speciesData twice, to generate some objects for fitting
do.call(setPaths, dataPrepPaths)

dataPrepParams <- list(
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
