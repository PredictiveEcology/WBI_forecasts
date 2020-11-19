#this should call the study area module

do.call(setPaths, preamblePaths)

preambleParams <- list(
  WBI_dataprep_studyArea = list(
    "studyAreaName" = studyAreaName,
    ".useCache" = TRUE
    "historicalFireYears" = 1991:2019 #RIA is now same as everywhere else
  )
)

simOutPreamble <- Cache(simInitAndSpades,
                        times = list(start = 0, end = 1),
                        params = preambleParams,
                        modules = c("WBI_dataPrep_studyArea"),
                        objects = preambleObjects,
                        paths = preamblePaths,
                        userTags = c('WBI_dataPrep_studyArea', studyAreaName),
                        useCloud = useCloudCache,
                        cloudFolderID = cloudCacheFolderID
)
