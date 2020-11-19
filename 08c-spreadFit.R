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
  fireSense_formula = simDataPrep$fireSense_formula
)

#  lower asymptote, upper asymptote, (inflection point), slope at inflection pt, asymmetry
#Note this is not from the fireSense_tutorial. No defaults on params..
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
    lower = lower,
    upper = upper
  ))

# Setting up IP's for paralelizing
cores <- makeIpsForClusters(module = "fireSense",
                            availableCores = c(9,   9,   9,   9,  19,   9,   9,   9,   8))




#
devtools::load_all("../fireSenseUtils") #during development
spreadSim <- simInit(times = list(start = 0, end = 1),
                     params = spreadFitParams,
                     modules = 'fireSense_SpreadFit',
                     paths = spreadFitPaths,
                     objects = spreadFitObjects)
spreadOut <- spades(spreadSim)
