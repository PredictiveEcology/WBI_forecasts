do.call(setPaths, ignitionFitPaths)

#ub and lb have to be provided for now

biggestObj <- as.numeric(object.size(simDataPrep$fireSense_ignitionCovariates))/1e6 * 1.2

nCores <- pemisc::optimalClusterNum(biggestObj)/2 - 4 #56, 28 both hit errors
ignitionFitParams <- list(
  fireSense_IgnitionFit = list(
    cores = nCores,
    fireSense_ignitionFormula = simDataPrep$fireSense_ignitionFormula,
    lb = list(coef = 1,
              knots = 0),
    #I don't know if this is the MDC value of the knot....
    #if using binomial need to pass theta to lb and ub
    ub = list(coef = 1,
              knots = round(quantile(simDataPrep$fireSense_ignitionCovariates$MDC, probs = 0.6), digits = 0))
  )
)

ignitionFitObjects <- list(
  fireSense_ignitionCovariates = simDataPrep$fireSense_ignitionCovariates
)

# devtools::load_all("../fireSenseUtils")
ignitionSim <- simInit(times = list(start = 0, end = 1),
                       params = ignitionFitParams,
                       modules = "fireSense_IgnitionFit",
                       paths = ignitionFitPaths,
                       objects = ignitionFitObjects)
ignitionOut <- spades(ignitionSim)
