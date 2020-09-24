#this should call the study area module

do.call(setPaths, preamblePaths)

preambleParams <- list(
  WBI_dataprep_studyArea = list(
    'studyAreaName' = studyAreaName
  )
)


simOutPreamble <- Cache(simInitAndSpades,
                        times = list(start = 0, end = 1),
                        params = preambleParams,
                        modules = c("WBI_dataPrep_studyArea"),
                        objects = preambleObjects,
                        paths = preamblePaths,
                        omitArgs = c("paths"),
                        userTags = c('WBI_dataPrep_studyArea', studyAreaName),
                        useCloud = useCloudCache,
                        cloudFolderID = cloudCacheFolderID)
