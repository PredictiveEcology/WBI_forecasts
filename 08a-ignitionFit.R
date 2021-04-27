do.call(setPaths, ignitionFitPaths)

source("05-google-ids.R")
newGoogleIDs <- gdriveSims[["ignitionOut"]] == ""

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
    # .plotInitialTime = 1,
    # .plots = 'png',
    cores = nCores,
    fireSense_ignitionFormula = form,
    lb = list(coef = 0,
              knots = list('MDC' = round(quantile(fSsimDataPrep$fireSense_ignitionCovariates$MDC,
                                                  probs = 0.05), digits = 0))),
    ub = list(coef = 20,
              knots = list('MDC' = round(quantile(fSsimDataPrep$fireSense_ignitionCovariates$MDC,
                                                  probs = 0.8), digits = 0))),
    family = quote(MASS::negative.binomial(theta = 1, link = "identity")),
    iterDEoptim = 300
  )
)

ignitionFitObjects <- list(
  fireSense_ignitionCovariates = fSsimDataPrep$fireSense_ignitionCovariates,
  ignitionFitRTM = fSsimDataPrep$ignitionFitRTM
)

#dignitionOut <- file.path(Paths$outputPath, paste0("ignitionOut_", studyAreaName)) %>%
#  checkPath(create = TRUE)
#aignitionOut <- paste0(dignitionOut, ".7z")
fignitionOut <- file.path(Paths$outputPath, paste0("ignitionOut_", studyAreaName, ".qs"))
if (isTRUE(usePrerun)) {
  if (!file.exists(fignitionOut)) {
    googledrive::drive_download(file = as_id(gdriveSims[["ignitionOut"]]), path = fignitionOut)
  }
  #if (!dir.exists(dignitionOut) || length(list.files(dignitionOut)) == 0) {
  #  googledrive::drive_download(file = as_id(gdriveSims[["ignitionOutArchive"]]), path = aignitionOut)
  #  archive::archive_extract(basename(aignitionOut), dirname(aignitionOut))
  #}
  ignitionOut <- loadSimList(fignitionOut)
} else {
  ignitionOut <- Cache(
    simInitAndSpades,
    times = list(start = 0, end = 1),
    # ignitionSim <- simInit(times = list(start = 0, end = 1),
    params = ignitionFitParams,
    modules = "fireSense_IgnitionFit",
    paths = ignitionFitPaths,
    objects = ignitionFitObjects,
    userTags = c("ignitionFit")
  )

  if (isTRUE(reupload)) {
    saveSimList(
      sim = ignitionOut,
      filename = fignitionOut,
      #filebackedDir = dignitionOut,
      fileBackend = 2
    )
    #archive::archive_write_dir(archive = aignitionOut, dir = dignitionOut)

    if (isTRUE(newGoogleIDs)) {
      googledrive::drive_put(media = fignitionOut, path = gdriveURL, name = basename(fignitionOut), verbose = TRUE)
      #googledrive::drive_put(media = aignitionOut, path = gdriveURL, name = basename(aignitionOut), verbose = TRUE)
    } else {
      googledrive::drive_update(file = as_id(gdriveSims[["ignitionOut"]]), media = fignitionOut)
      #googledrive::drive_update(file = as_id(gdriveSims[["ignitionOutArchive"]]), media = aignitionOut)
    }
  }

  if (requireNamespace("slackr") & file.exists("~/.slackr")) {
    slackr::slackr_setup()
    slackr::slackr_msg(
      paste0("`fireSense_IgnitionFit` for ", studyAreaName, " completed on host `", Sys.info()[["nodename"]], "`."),
      channel = config::get("slackchannel"), preformatted = FALSE
    )
  }
}
