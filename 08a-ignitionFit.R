do.call(setPaths, ignitionFitPaths)

#climVar may become a principal component eventually, hence this format
climVar <- simDataPrep$fireSense_ignitionCovariates[, 2]

#This needs work. Need to figure out what these are supposed to look like
ones <- rep(1, times = ncol(simDataPrep$fireSense_ignitionCovariates) - 3)
zeroes <- rep(0, times = length(ones))
upper = c(round(max(climVar) * 1.05, digits = 0), ones)
lower = c(min(climVar) * 0.95, zeroes)
names(lower) = names(simDataPrep$fireSense_ignitionCovariates)[2:c(length(upper) + 1)]
names(upper) = names(lower)



ignitionFitParams <- list(
  fireSense_IgnitionFit = list(
    fireSense_ignitionFormula = simDataPrep$fireSense_ignitionFormula,
    ub = list("coef" = upper),
    lb = list("coef" = lower)
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
