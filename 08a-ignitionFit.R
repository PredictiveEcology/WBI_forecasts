do.call(setPaths, ignitionFitPaths)

#ub and lb have to be provided for now

biggestObj <- as.numeric(object.size(simDataPrep$fireSense_ignitionCovariates))/1e6 * 1.2

if (studyAreaName == "AB") {
  form <- paste0("ignitions ~ youngAge:MDC + nonForest_highFlam:MDC + ",
                 "nonForest_lowFlam:MDC + class2:MDC + class3:MDC + ",
                 "youngAge:pw(MDC, k_YA) + nonForest_lowFlam:pw(MDC, k_NFLF) + ",
                 "nonForest_highFlam:pw(MDC, k_NFHF) + class2:pw(MDC, k_class2) + ",
                 "class3:pw(MDC, k_class3) - 1")
  # form <- paste0("ignitions ~ "
  #                , "youngAge "
  #                , "+ nonForest_highFlam "
  #                #"+ nonForest_lowFlam ",
  #                , "+ class2:MDC "
  #                , "+ class3:MDC "
  #                #"youngAge:pw(MDC, k_YA) + ",
  #                #"nonForest_lowFlam:pw(MDC, k_YA) + ",
  #                #"nonForest_highFlam:pw(MDC, k_YA) + ",
  #                , "+ class2:pw(MDC, k_class2) "
  #                # , "+ class3:pw(MDC, k_class3) "
  #                , "- 1"
  #                )
  # form <- paste0("ignitions ~ "
  #                , "MDC + "
  #                #, "youngAge +"
  #                , "+ nonForest_highFlam "
  #                #"+ nonForest_lowFlam ",
  #                , "+ class2:MDC "
  #                , "+ class3:MDC "
  #                #"youngAge:pw(MDC, k_YA) + ",
  #                #"nonForest_lowFlam:pw(MDC, k_YA) + ",
  #                #"nonForest_highFlam:pw(MDC, k_YA) + ",
  #                , "+ class2:pw(MDC, k_class2) "
  #                # , "+ class3:pw(MDC, k_class3) "
  #                , "- 1"
  # )
  #form <- "ignitions ~ youngAge:MDC + MDC:nonForest_highFlam + MDC:class2 + MDC:class3 + class2:pw(MDC, k_class2) -1"

} else {
  form <- simDataPrep$fireSense_ignitionFormula
}

nCores <- pmin(14, pemisc::optimalClusterNum(biggestObj)/2 - 6) #56, 28 both hit errors
ignitionFitParams <- list(
  fireSense_IgnitionFit = list(
    cores = nCores,
    fireSense_ignitionFormula = form,
    lb = list(coef = 0,
              knots = round(quantile(simDataPrep$fireSense_ignitionCovariates$MDC, probs = 0.05), digits = 0)),
    #I don't know if this is the MDC value of the knot....
    #if using binomial need to pass theta to lb and ub
    ub = list(coef = 4,
              knots = round(quantile(simDataPrep$fireSense_ignitionCovariates$MDC, probs = 0.8), digits = 0)),
    family = quote(MASS::negative.binomial(theta = 1, link = "identity")),
    iterDEoptim = 300
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
