#this will become Main, but for now, i need something fast.
do.call(setPaths, dynamicPaths)
dynamicModules <- list("fireSense_dataPrepPredict") #Biomass_core, etc will be added
dynamicObjects <- list(climateComponentsTouse = simDataPrep$climateComponentsToUse,
                       cohortData = simDataPrep$cohortData2011,
                       flammableRTM = simDataPrep$flammableRTM,
                       landcoverDT = simDataPrep$landcoverDT,
                       nonForest_timeSinceDisturbance = simDataPrep$nonForest_timeSinceDisturbance,
                       #this is the 2011 TSD - perhaps I should rename it in dataPrepFit to make it explicit?
                       PCAveg = simDataPrep$PCAveg,
                       pixelGroupMap = simDataPrep$pixelGroupMap2011,
                       projectedClimateLayers = simOutPreamble$projectedClimateRasters,
                       sppEquiv = simDataPrep$sppEquiv,
                       terrainDT = simDataPrep$terrainDT,
                       vegComponentsToUse = simDataPrep$vegComponfentsToUse)

dynamicParams <- list(
  fireSense_dataPrepPredict = list(
    'fireTimeStep' = 1,
    'sppEquivCol' = simOutPreamble$sppEquivCol,
    'whichModulesToPrepare' = c('fireSense_SpreadPredict', 'fireSense_IgnitionPredict'),
    'missingLCCgroup' = simDataPrep@params$fireSense_dataPrepFit$missingLCCgroup
  )
)
devtools::load_all("../fireSenseUtils")
mySim <- simInit(times = list(start = 2011, end = 2012),
                 modules = dynamicModules,
                 objects = dynamicObjects,
                 params = dynamicParams,
                 paths = dynamicPaths)
simOut <- spades(mySim)


