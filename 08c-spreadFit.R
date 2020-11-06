do.call(setPaths, spreadFitPaths)

spreadFitObjects <- list(
  fireSense_fitCovariates = simDataPrep$fireSense_fitCovariates,
  firePolys = simDataPrep$firePolys,
  firePoints = simDataPrep$firePoints,
  flammableMap = simDataPrep$flammableMap,
  studyArea = simDataPrep$studyArea,
  rasterToMatch = simDataPrep$rasterToMatch
)
spreadFitParams <- list(
  fireSense_SpreadFit = list(
    # I don't know what will go here yet
    # likely a bunch of DEOptim things and cloudCache params
  )
)

devtools::load_all("../fireSenseUtils") #during development
spreadSim <- simInit(times = list(start = 0, end = 1),
                     params = spreadFitParams,
                     modules = 'fireSense_SpreadFit',
                     paths = spreadFitPaths,
                     objects = spreadFitObjects)
spreadOut <- spades(spreadSim)

