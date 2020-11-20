################################################################################

do.call(setPaths, spreadFitPaths)

spreadFitObjects <- list(
  fireSense_annualSpreadFitCovariates = simDataPrep$fireSense_annualSpreadFitCovariates,
  fireSense_nonAnnualSpreadFitCovariates = simDataPrep$fireSense_nonAnnualSpreadFitCovariates,
  firePolys = simDataPrep$firePolys,
  firePoints = simDataPrep$firePoints,
  flammableRTM = simDataPrep$flammableRTM,
  studyArea = simDataPrep$studyArea,
  rasterToMatch = simDataPrep$rasterToMatch,
  fireSense_formula = simDataPrep$fireSense_formula,
)

#  lower asymptote, upper asymptote, (inflection point), slope at inflection pt, asymmetry
#Note this is not from the fireSense_tutorial. No defaults on params yet...
lowerParams <- c(-16, -16, -16, -16, -16, -16)
upperParams <- c(32, 32, 32, 32, 32, 32)
# Spread log function bounds

# for logistic3p
#lower <- c(0.22, 0.001, 0.001, lowerParams)
#upper <- c(0.29, 10, 10, upperParams)

#this is study area specific and might be be retrieved by WBI_dataPrep_studyArea?
lower <- c(0.22, 0.001, lowerParams)
upper <- c(0.29, 10, upperParams)

if (!isRstudioServer()) {
  cores <- pemisc::makeIpsForClustersBoreaCloud(module = "fireSense",
                                                ipEnd = c(97, 189, 220, 106, 217),
                                                localHostEndIp = 97,
                                                availableRAM = c(500, 500, 500, 250, 250),
                                                availableCores = c(24, 25, 25, 13, 13))
}

spreadFitParams <- list(
  fireSense_SpreadFit = list(
    'lower' = lower,
    'upper' = upper,
    "cores" = if (isRstudioServer()) NULL else cores, #rep("localhost", 40), #cores,
    "iterDEoptim" = 150,
    "iterStep" = 150,
    "debugMode" = FALSE, # DEoptim may spawn many machines via PSOCK --> may be better from cmd line
    "rescaleAll" = TRUE,
    "NP" = length(cores),
    "objFunCoresInternal" = 3L,
    "maxFireSpread" = 0.3,
    "objfunFireReps" = 100,
    "verbose" = TRUE,
    "trace" = 1,
    "visualizeDEoptim" = TRUE,
    "cacheId_DE" = paste0("DEOptim_", studyAreaName), # This is NWT DEoptim Cache
    "cloudFolderID_DE" = cloudCacheFolderID,
    "useCloud_DE" = TRUE
  ))


spreadSim <- simInit(times = list(start = 0, end = 1),
                     params = spreadFitParams,
                     modules = 'fireSense_SpreadFit',
                     paths = spreadFitPaths,
                     objects = spreadFitObjects)
spreadOut <- spades(spreadSim)
