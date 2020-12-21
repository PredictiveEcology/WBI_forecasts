################################################################################

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

## so far the minimum PCA value is -9000 (e.g. 9 standard deviations x1000)
## but the maximum is 27000! In theory these are symmetrical
## so for safety, -35000 to 35000. need more info
lowerParams <- rep(-16, times = c(ncol(simDataPrep$fireSense_annualSpreadFitCovariates[[1]]) +
                                     ncol(simDataPrep$fireSense_nonAnnualSpreadFitCovariates[[1]])
                   - 2))

upperParams <- rep(32, times = length(lowerParams))

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
                                   sizeGbEachProcess = 10)
} else if (peutils::user("achubaty")) {
  pemisc::makeIpsForNetworkCluster(ipStart = "192.168.0",
                                   ipEnd = c(220, 223, 224),
                                   localHostEndIp = 224,
                                   availableRAM = c(500, 64, 500),
                                   availableCores = c(64, 16, 96),
                                   proc = "cores",
                                   nProcess = 8,
                                   internalProcesses = 10,
                                   sizeGbEachProcess = 10)
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
    "lower" = lower,
    "upper" = upper,
    'cores' = cores,
    # "cores" = if (isRstudioServer()) NULL else cores, #rep("localhost", 40), #cores,
    "iterDEoptim" = 150,
    "iterStep" = 150,
    "rescaleAll" = TRUE,
    "NP" = length(cores),
    "objFunCoresInternal" = 3L,
    "maxFireSpread" = 0.28,
    "objfunFireReps" = 100,
    "verbose" = TRUE,
    "trace" = 1,
    # "debugMode" = if (isRstudioServer()) TRUE else FALSE, # DEoptim may spawn many machines via PSOCK --> may be better from cmd line
    'debugMode' = FALSE,
    "visualizeDEoptim" = TRUE,
    # "cacheId_DE" = paste0("DEOptim_", studyAreaName), # This is NWT DEoptim Cache
    "cloudFolderID_DE" = cloudCacheFolderID,
    "useCloud_DE" = FALSE
  )
)

# Because fireSenseUtils MUST be the same version locally as in the cluster,
#   there is no point in installing it via local. This means that local changes
#   must be pushed to github -- can change from development to a working branch,
#   if desired
devtools::install_github("PredictiveEcology/fireSenseUtils@development", dependencies = TRUE)
# Only install fireSenseUtils if changed
# pathToFireSenseUtils <- "../fireSenseUtils"
# curDigest <- digest::digest(lapply(dir(pathToFireSenseUtils, recursive = TRUE, full.names = TRUE), function(file) digest::digest(file = file)))
# fsud <- file.path(spreadFitPaths$cachePath, "fireSpreadUtilsDigest")
# prevDigest <- readRDS(fsud)
# if (!identical(prevDigest, curDigest)) {
#   saveRDS(curDigest, file = fsud)
#   devtools::install, pathToFireSenseUtils, upgrade = FALSE, dependencies = FALSE) #install development fireSense
# }

#add tags when it stabilizes
# rm(biomassMaps2001, biomassMaps2011)
spreadSim <- simInit(times = list(start = 0, end = 1),
                     params = spreadFitParams,
                     modules = 'fireSense_SpreadFit',
                     paths = spreadFitPaths,
                     objects = spreadFitObjects)
spreadOut <- spades(spreadSim)
