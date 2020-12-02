## TODO: not sure what will go here as most are SA-specific

preambleObjects <- list() # no objects as studyArea module gets everything for now

## TODO: this will be passed to the dataprep parameters when preparing cohortData for fitting -
## they are potentially different from the dynamic run of biomass_borealDataPrep
dataPrep <- list(
  subsetDataBiomassModel = 50,
  pixelGroupAgeClass = 20,
  successionTimeStep = 10,
  useCache = TRUE
)
