do.call(setPaths, ignitionFitPaths)

#climVar may become a principal component eventually, hence this format
climVar <- simDataPrep$fireSense_ignitionCovariates[, 2]

ignitionFitParams <- list(
  fireSense_IgnitionFit = list(
    fireSense_ignitionFormula = simDataPrep$fireSense_ignitionFormula
  )
)

ignitionFitObjects <- list(
  fireSense_ignitionCovariates = simDataPrep$fireSense_ignitionCovariates,
)


ignitionSim <- simInit(times = list(start = 0, end = 1),
                       params = ignitionFitParams,
                       modules = "fireSense_IgnitionFit",
                       paths = ignitionFitPaths,
                       objects = ignitionFitObjects)
ignitionOut <- spades(ignitionSim)
