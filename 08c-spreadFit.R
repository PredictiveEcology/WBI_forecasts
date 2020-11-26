################################################################################

do.call(setPaths, spreadFitPaths)

spreadFitObjects <- list(
  fireBufferedListDT = simDataPrep$fireBufferedListDT,
  fireSense_annualSpreadFitCovariates = simDataPrep$fireSense_annualSpreadFitCovariates,
  fireSense_nonAnnualSpreadFitCovariates = simDataPrep$fireSense_nonAnnualSpreadFitCovariates,
  firePolys = simDataPrep$firePolys,
  firePoints = simDataPrep$firePoints,
  flammableRTM = simDataPrep$flammableRTM,
  studyArea = simDataPrep$studyArea,
  rasterToMatch = simDataPrep$rasterToMatch,
  fireSense_formula = simDataPrep$fireSense_formula
)

#so far the minimum PCA value is -9000 (e.g. 9 standard deviations x1000)
#but the maximum is 27000! In theory these are symmetrical
#so for safety, -35000 to 35000. need more info
lowerParams <- rep(-35000, times = c(ncol(simDataPrep$fireSense_annualSpreadFitCovariates[[1]]) +
                                     ncol(simDataPrep$fireSense_nonAnnualSpreadFitCovariates[[1]])
                   - 2))

upperParams <- rep(35000, times = length(lowerParams))

# Spread log function bounds

# for logistic3p
#lower <- c(0.22, 0.001, 0.001, lowerParams)
#upper <- c(0.29, 10, 10, upperParams)

lower <- c(0.22, 0.001, lowerParams)
upper <- c(0.29, 10, upperParams)

cores <- pemisc::makeIpsForClustersBoreaCloud(module = "fireSense",
                                                ipEnd = c(97, 189, 220, 106, 217),
                                                localHostEndIp = 97,
                                                availableRAM = c(500, 500, 500, 250, 250),
                                                availableCores = c(24, 25, 25, 13, 13))


cloudCacheFolderID <- drive_mkdir(name = paste0('spreadFit_', studyAreaName),
                                  path = as_id('https://drive.google.com/drive/folders/18aXrRWI3sc6WUG56qaTaa8YXMlCWFS6m?usp=sharing'))
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
    "maxFireSpread" = 0.3,
    "objfunFireReps" = 100,
    "verbose" = TRUE,
    "trace" = 1,
    # "debugMode" = if (isRstudioServer()) TRUE else FALSE, # DEoptim may spawn many machines via PSOCK --> may be better from cmd line
    'debugMode' = FALSE,
    "visualizeDEoptim" = TRUE,
    "cacheId_DE" = paste0("DEOptim_", studyAreaName), # This is NWT DEoptim Cache
    "cloudFolderID_DE" = cloudCacheFolderID,
    "useCloud_DE" = FALSE
  ))

devtools::load_all("../fireSenseUtils") #install development fireSense
#add tags when it stabilizes
# rm(biomassMaps2001, biomassMaps2011)
spreadSim <- simInit(times = list(start = 0, end = 1),
                     params = spreadFitParams,
                     modules = 'fireSense_SpreadFit',
                     paths = spreadFitPaths,
                     objects = spreadFitObjects)
spreadOut <- spades(spreadSim)
