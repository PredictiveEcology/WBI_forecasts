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

lowerParamsNonAnnual <- rep(-16, times = ncol(simDataPrep$fireSense_nonAnnualSpreadFitCovariates[[1]]) - 1)
lowerParamsAnnual <- c(-16, -16)
upperParamsNonAnnual <- rep(32, times = length(lowerParamsNonAnnual))
upperParamsAnnual <- c(32, 32)
lowerParams <- c(lowerParamsAnnual, lowerParamsNonAnnual)
upperParams <- c(upperParamsAnnual, upperParamsNonAnnual)

## Spread log function bounds

## for logistic3p
# lower <- c(0.22, 0.001, 0.001, lowerParams)
# upper <- c(0.29, 10, 10, upperParams)

lower <- c(0.22, 0.001, lowerParams)
upper <- c(0.28, 10, upperParams)

cores <- if (peutils::user("ieddy")) {
  pemisc::makeIpsForNetworkCluster(ipStart = "10.20.0",
                                   ipEnd = c(97, 189, 220, 106, 217),
                                   localHostEndIp = 97,
                                   availableCores = c(24, 25, 25, 13, 13),
                                   availableRAM = c(500, 500, 500, 250, 250),
                                   proc = "cores",
                                   nProcess = 8,
                                   internalProcesses = 10,
                                   sizeGbEachProcess = 1)
} else if (peutils::user("achubaty") && Sys.info()["nodename"] == "forcast02") {
  rep("localhost", 80)
} else if (peutils::user("emcintir")) {
  rep("localhost", 36)
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
    "iterDEoptim" = 150,
    "iterStep" = 150,
    "iterThresh" = 192L,
    "lower" = lower,
    "maxFireSpread" = 0.28,
    "NP" = length(cores),
    "objFunCoresInternal" = 1L,
    "objfunFireReps" = 100,
    "rescaleAll" = TRUE,
    "trace" = 1,
    "SNLL_FS_thresh" = NULL, ## NULL means 'autocalibrate' to find suitable threshold value
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
