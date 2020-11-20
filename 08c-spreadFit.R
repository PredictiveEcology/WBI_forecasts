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
    #initialpop = if (exists("aa")) aa$member$pop else NULL#[sample(seq_len(NROW(aa$member$pop)), length(cores)),]
    # "40927e9ca42d33b3", "56769e2b2edfe8ab",  "c3af84b504e99a5d", # This is NWT DEoptim Cache, newer to older
    "cacheId_DE" = runNamesList()[RunName == runName,
                                  DEoptimCache], # This is NWT DEoptim Cache
    "cloudFolderID_DE" = "1kUZczPyArGIIkbl-4_IbtJWBhVDveZFZ",
    "useCloud_DE" = TRUE
  ))

# Setting up IP's for paralelizing
cores <- pemisc::makeIpsForClustersBoreaCloud(module = "fireSense",
                                              ipEnd = c(97, 189, 220, 106, 217),
                                              localHostEndIp = 97,
                                              availableCores = c(24, 25, 25, 13, 13))

#
devtools::load_all("../fireSenseUtils") #during development
spreadSim <- simInit(times = list(start = 0, end = 1),
                     params = spreadFitParams,
                     modules = 'fireSense_SpreadFit',
                     paths = spreadFitPaths,
                     objects = spreadFitObjects)
spreadOut <- spades(spreadSim)
