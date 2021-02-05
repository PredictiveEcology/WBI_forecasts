do.call(setPaths, spreadFitPaths)

spreadFitObjects <- list(
  fireBufferedListDT = simDataPrep$fireBufferedListDT,
  fireSense_annualSpreadFitCovariates = simDataPrep$fireSense_annualSpreadFitCovariates,
  fireSense_nonAnnualSpreadFitCovariates = simDataPrep$fireSense_nonAnnualSpreadFitCovariates,
  fireSense_spreadFormula = simDataPrep$fireSense_spreadFormula,
  firePolys = simDataPrep$firePolys,
  flammableRTM = simDataPrep$flammableRTM,
  spreadFirePoints = simDataPrep$spreadFirePoints,
  studyArea = simDataPrep$studyArea,
  rasterToMatch = simDataPrep$rasterToMatch
)

extremeVals <- 10
lowerParamsNonAnnual <- rep(-extremeVals, times = ncol(simDataPrep$fireSense_nonAnnualSpreadFitCovariates[[1]]) - 1)
lowerParamsAnnual <- c(-extremeVals, -extremeVals)
upperParamsNonAnnual <- rep(extremeVals, times = length(lowerParamsNonAnnual))
upperParamsAnnual <- c(extremeVals, extremeVals)
lowerParams <- c(lowerParamsAnnual, lowerParamsNonAnnual)
upperParams <- c(upperParamsAnnual, upperParamsNonAnnual)

## Spread log function bounds

## for logistic3p
# lower <- c(0.22, 0.001, 0.001, lowerParams)
# upper <- c(0.29, 10, 10, upperParams)

lower <- c(0.22, 0.001, lowerParams)
upper <- c(0.286, 10, upperParams)
dfT <- cbind(c("lower", "upper"), t(data.frame(lower, upper)))
message("Upper and Lower parameter bounds are:")
Require:::messageDF(dfT)

localHostEndIp <-
  switch(peutils::user(),
         "ieddy" = 97,
         "emcintir" = 213 )

cores <-  if (peutils::user("ieddy")) {
  pemisc::makeIpsForNetworkCluster(ipStart = "10.20.0",
                                   ipEnd = c(97, 189, 220, 106, 217),
                                   availableCores = c(46, 46, 46, 28, 28),
                                   availableRAM = c(500, 500, 500, 250, 250),
                                   localHostEndIp = localHostEndIp,
                                   proc = "cores",
                                   nProcess = length(lower),
                                   internalProcesses = 10,
                                   sizeGbEachProcess = 1)
} else if (peutils::user("achubaty") && Sys.info()["nodename"] == "forcast02") {
  rep("localhost", 90)
} else if (peutils::user("emcintir")) {
  pemisc::makeIpsForNetworkCluster(ipStart = "10.20.0",
                                   #ipEnd = c(97, 189, 220, 106, 217),
                                   #ipEnd = c(97, 189, 220, 217),#, 106, 217, 213, 184),
                                   #availableCores = c(46, 46, 46, 28),#, 28, 28, 56, 28),
                                   #availableRAM = c(500, 500, 500, 250),#, 250, 250, 500, 250),
                                   ipEnd = c(106, 217, 213, 184),
                                   availableCores = c(22, 22, 40, 22),
                                   availableRAM = c(250, 250, 500, 250),
                                   localHostEndIp = localHostEndIp,
                                   proc = "cores",
                                   nProcess = length(lower),
                                   internalProcesses = 10,
                                   sizeGbEachProcess = 1)
} else {
  stop("please specify machines to use for spread fit")
}

# NPar <- length(lower)
# NP <- NPar * 10
# initialpop <- matrix(ncol = NPar, nrow = NP)

spreadFitParams <- list(
  fireSense_SpreadFit = list(
    # "cacheId_DE" = paste0("DEOptim_", studyAreaName), # This is NWT DEoptim Cache
    "cloudFolderID_DE" = cloudCacheFolderID,
    "cores" = cores,
    "debugMode" = FALSE,
    "iterDEoptim" = if (peutils::user("emcintir")) 150 else 150,
    "iterStep" = if (peutils::user("emcintir")) 150 else 150,
    "iterThresh" = 192L,
    "lower" = lower,
    "maxFireSpread" = max(0.28, upper[1]),
    "NP" = length(cores),
    "objFunCoresInternal" = 1L,
    "objfunFireReps" = 100,
    "rescaleAll" = TRUE,
    "trace" = 1,
    "SNLL_FS_thresh" = if (peutils::user("emcintir")) NULL else NULL,# NULL means 'autocalibrate' to find suitable threshold value
    "upper" = upper,
    "verbose" = TRUE,
    "visualizeDEoptim" = FALSE,
    "useCloud_DE" = useCloudCache,
    ".plotSize" = list(height = 1600, width = 2000)
  )
)

#add tags when it stabilizes
# rm(biomassMaps2001, biomassMaps2011)

spreadSim <- simInit(times = list(start = 0, end = 1),
                     params = spreadFitParams,
                     modules = "fireSense_SpreadFit",
                     paths = spreadFitPaths,
                     objects = spreadFitObjects)
spreadOut <- spades(spreadSim)
if (peutils::user("emcintir")) {
  saveName <- paste0("spreadOut_", Sys.Date(), "_Limit", extremeVals, "_",
                     spreadFitParams$fireSense_SpreadFit$iterDEoptim, "_",
                     "SNLL_FS_thresh", spreadFitParams$fireSense_SpreadFit$SNLL_FS_thresh,
                     "_", SpaDES.core::rndstr(1, 6))
  saveRDS(spreadOut, file = saveName)

}
