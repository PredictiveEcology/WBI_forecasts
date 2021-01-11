do.call(setPaths, preamblePaths)

preambleObjects <- list()

preambleParams <- list(
  WBI_dataPrep_studyArea = list(
    ".useCache" = TRUE,
    "historicalFireYears" = 1991:2019,
    "studyAreaName" = studyAreaName
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
