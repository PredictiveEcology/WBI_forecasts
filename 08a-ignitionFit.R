do.call(setPaths, ignitionFitPaths)

#ub and lb have to be provided for now

biggestObj <- as.numeric(object.size(fSsimDataPrep$fireSense_ignitionCovariates))/1e6 * 1.2

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
  form <- fSsimDataPrep$fireSense_ignitionFormula
}

nCores <- pmin(14, pemisc::optimalClusterNum(biggestObj)/2 - 6) #56, 28 both hit errors
ignitionFitParams <- list(
  fireSense_IgnitionFit = list(
    cores = nCores,
    fireSense_ignitionFormula = form,
    lb = list(coef = 0,
              knots = round(quantile(fSsimDataPrep$fireSense_ignitionCovariates$MDC, probs = 0.05), digits = 0)),
    #I don't know if this is the MDC value of the knot....
    #if using binomial need to pass theta to lb and ub
    ub = list(coef = 4,
              knots = round(quantile(fSsimDataPrep$fireSense_ignitionCovariates$MDC, probs = 0.8), digits = 0)),
    family = quote(MASS::negative.binomial(theta = 1, link = "identity")),
    iterDEoptim = 300
  )
)

ignitionFitObjects <- list(
  fireSense_ignitionCovariates = fSsimDataPrep$fireSense_ignitionCovariates
)

fsim <- file.path(Paths$outputPath, paste0("ignitionOut_", studyAreaName, ".qs"))
if (isTRUE(usePrerun)) {
  if (!file.exists(fsim)) {
    googledrive::drive_download(file = as_id(gdriveSims[["ignitionOut"]]), path = fsim)
  }
  ignitionOut <- loadSimList(fsim)
} else {
  ignitionOut <- Cache(simInitAndSpades,
                       times = list(start = 0, end = 1),
                       # ignitionSim <- simInit(times = list(start = 0, end = 1),
                       params = ignitionFitParams,
                       modules = "fireSense_IgnitionFit",
                       paths = ignitionFitPaths,
                       objects = ignitionFitObjects,
                       userTags = c("ignitionFit"))
  saveSimList(ignitionOut, fsim, fileBackend = 2)
  if (isTRUE(firstRun)) {
    googledrive::drive_put(media = fsim, path = gdriveURL, name = basename(fsim), verbose = TRUE)
  } else {
    googledrive::drive_update(file = as_id(gdriveSims[["ignitionOut"]]), media = fsim)
  }
}
