.starttime <- Sys.time()
studyAreaName <- 'RIA'
#BC AB SK MB YK NWT
useCloudCache<- FALSE
cloudCacheFolderID <- NULL

#this will be passed to the dataprep parameters when preparing cohortData for fitting -
#they are potentially different from the dynamic run of biomass_borealDataPrep
dataPrep <- list(
  subsetDataBiomassModel = 50,
  pixelGroupAgeClass = 20,
  successionTimeStep = 10,
  useCache = TRUE)

httr::timeout(seconds = 10)
