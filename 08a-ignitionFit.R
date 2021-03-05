do.call(setPaths, ignitionFitPaths)

#ub and lb have to be provided for now

biggestObj <- as.numeric(object.size(simDataPrep$fireSense_ignitionCovariates))/1e6 * 1.2

nCores <- pemisc::optimalClusterNum(biggestObj)/2 - 6 #56, 28 both hit errors
ignitionFitParams <- list(
  fireSense_IgnitionFit = list(
    cores = 14,#nCores,
    fireSense_ignitionFormula = simDataPrep$fireSense_ignitionFormula,
    lb = list(coef = 0,
              knots = round(quantile(simDataPrep$fireSense_ignitionCovariates$MDC, probs = 0.1), digits = 0)),
    #I don't know if this is the MDC value of the knot....
    #if using binomial need to pass theta to lb and ub
    ub = list(coef = 2,
              knots = round(quantile(simDataPrep$fireSense_ignitionCovariates$MDC, probs = 0.9), digits = 0)),
    family = quote(MASS::negative.binomial(theta = 1, link = "identity"))
  )
)

ignitionFitObjects <- list(
  fireSense_ignitionCovariates = simDataPrep$fireSense_ignitionCovariates
)

# devtools::load_all("../fireSenseUtils")
ignitionOut <- simInitAndSpades(times = list(start = 0, end = 1),
                                # ignitionSim <- simInit(times = list(start = 0, end = 1),
                                params = ignitionFitParams,
                                modules = "fireSense_IgnitionFit",
                                paths = ignitionFitPaths,
                                objects = ignitionFitObjects)
#ignitionOut <- spades(ignitionSim)
