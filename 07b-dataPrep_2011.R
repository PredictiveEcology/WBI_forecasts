## NOTE: 07a-dataPrep_2001.R needs to be run before this script

source("05-google-ids.R")
newGoogleIDs <- gdriveSims[["biomassMaps2011"]] == ""

dataPrepParams2011 <- dataPrepParams2001
dataPrepParams2011$Biomass_speciesData$types <- "KNN"
dataPrepParams2011$Biomass_speciesData$dataYear <- 2011
dataPrepParams2011$Biomass_speciesData$.studyAreaName <- paste0(studyAreaName, 2011)
dataPrepParams2011$Biomass_borealDataPrep$dataYear <- 2011
dataPrepParams2011$Biomass_borealDataPrep$.studyAreaName <- paste0(studyAreaName, 2011)

dataPrepOutputs2011 <- data.frame(
  objectName = c("cohortData",
                 "pixelGroupMap",
                 "speciesLayers",
                 "standAgeMap",
                 "rawBiomassMap"),
  saveTime = 2011,
  file = c("cohortData2011_fireSense.rds",
           "pixelGroupMap2011_fireSense.rds",
           "speciesLayers2011_fireSense.rds",
           "standAgeMap2011_borealDataPrep.rds",
           "rawBiomassMap2011_borealDataPrep.rds") # Currently not needed
)

dataPrepObjects2011 <- dataPrepObjects
dataPrepObjects2011$standAgeMap <- simOutPreamble$standAgeMap2011

#dbiomassMaps2011 <- file.path(Paths$outputPath, paste0("biomassMaps2011_", studyAreaName)) %>%
#  checkPath(create = TRUE)
#abiomassMaps2011 <- paste0(dbiomassMaps2011, ".7z")
fbiomassMaps2011 <- file.path(Paths$outputPath, paste0("biomassMaps2011_", studyAreaName, ".qs"))
if (isTRUE(usePrerun)) {
  if (!file.exists(fbiomassMaps2011)) {
    googledrive::drive_download(file = as_id(gdriveSims[["biomassMaps2011"]]), path = fbiomassMaps2011)
  }
  #if (!dir.exists(dbiomassMaps2011) || length(list.files(dbiomassMaps2011)) == 0) {
  #  googledrive::drive_download(file = as_id(gdriveSims[["biomassMaps2011Archive"]]), path = abiomassMaps2011)
  #  archive::archive_extract(basename(abiomassMaps2011), dirname(abiomassMaps2011))
  #}
  biomassMaps2011 <- loadSimList(fbiomassMaps2011)

  ## TODO: temp until bug in qs resolved
  biomassMaps2011$cohortData <- as.data.table(biomassMaps2011$cohortData)
  biomassMaps2011$minRelativeB <- as.data.table(biomassMaps2011$minRelativeB)
  biomassMaps2011$pixelFateDT <- as.data.table(biomassMaps2011$pixelFateDT)
  biomassMaps2011$species <- as.data.table(biomassMaps2001$species)
  biomassMaps2011$speciesEcoregion <- as.data.table(biomassMaps2011$speciesEcoregion)
  biomassMaps2011$sppEquiv <- as.data.table(biomassMaps2011$sppEquiv)
  biomassMaps2011$sufficientLight <- as.data.frame(biomassMaps2011$sufficientLight)
  ## end TODO
} else {
  biomassMaps2011 <- Cache(
    simInitAndSpades,
    times = list(start = 2011, end = 2011),
    params = dataPrepParams2011,
    modules = list("Biomass_speciesData", "Biomass_borealDataPrep"),
    objects = dataPrepObjects2011,
    paths = getPaths(),
    loadOrder = c("Biomass_speciesData", "Biomass_borealDataPrep"),
    clearSimEnv = TRUE,
    # outputs = dataPrepOutputs2011,
    .plots = "png",
    useCloud = useCloudCache,
    cloudFolderID = cloudCacheFolderID,
    userTags = c("dataPrep2011", studyAreaName)
  )

  if (isTRUE(reupload)) {
    saveSimList(
      sim = biomassMaps2011,
      filename = fbiomassMaps2011,
      #filebackedDir = dbiomassMaps2011,
      fileBackend = 2
    )
    #archive::archive_write_dir(archive = abiomassMaps2011, dir = dbiomassMaps2011)

    if (isTRUE(newGoogleIDs)) {
      googledrive::drive_put(media = fbiomassMaps2011, path = gdriveURL, name = basename(fbiomassMaps2011), verbose = TRUE)
      #googledrive::drive_put(media = abiomassMaps2011, path = gdriveURL, name = basename(abiomassMaps2011), verbose = TRUE)
    } else {
      googledrive::drive_update(file = as_id(gdriveSims[["biomassMaps2011"]]), media = fbiomassMaps2011)
      #googledrive::drive_update(file = as_id(gdriveSims[["biomassMaps2011Archive"]]), media = abiomassMaps2011)
    }
  }
}

rm(dataPrepOutputs2001, dataPrepParams2001)
rm(dataPrepOutputs2011, dataPrepParams2011)
