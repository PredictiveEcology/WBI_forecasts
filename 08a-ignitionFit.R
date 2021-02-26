do.call(setPaths, ignitionFitPaths)

#ub and lb have to be provided for now

ignitionFitParams <- list(
  fireSense_IgnitionFit = list(
    cores = 20,
    fireSense_ignitionFormula = simDataPrep$fireSense_ignitionFormula,
    lb = list(coef = 0,
              knots = 0),
    #I don't know if this is the MDC value of the knot....
    #if using binomial need to pass theta to lb and ub
    ub = list(coef = 1,
              knots = 100)
  )
)

ignitionFitObjects <- list(
  fireSense_ignitionCovariates = simDataPrep$fireSense_ignitionCovariates
)


ignitionSim <- simInit(times = list(start = 0, end = 1),
                       params = ignitionFitParams,
                       modules = "fireSense_IgnitionFit",
                       paths = ignitionFitPaths,
                       objects = ignitionFitObjects)
ignitionOut <- spades(ignitionSim)
