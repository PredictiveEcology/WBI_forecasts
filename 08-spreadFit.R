do.call(setPaths, spreadFitPaths)


spreadFitObjects <- list(
    fireSense_fitCovariates = simOutDataPrep$fireSenseCovariates,
    firePolys = simOutDataPrep$firePolys,
    firePoints = simOutDataPrep$firePoints,
    flammableMap = simOutDataPrep$flammableMap,
    studyArea = simOutDataPrep$studyArea,
    rasterToMatch = simOutDataPrep$rasterToMatch
)
spreadFitParams <- list(
  fireSense_SpreadFit = list(
    # I don't know what will go here yet
    # likely a bunch of DEOptim things and cloudCache params
  )
)

devtools::load_all("../fireSenseUtils") #during development
spreadSim <- simInit(times = list(start = 0, end =1),
                     params = spreadFitParams,
                     modules = 'fireSense_SpreadFit',
                     paths = spreadFitPaths,
                     objects = spreadFitObjects)
spreadOut <- spades(spreadSim)
