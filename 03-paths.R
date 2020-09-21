
#I assume we want a different cache for aspects that are only run once in advance (e.g. the 2011/2001 biomassBorealDataPreps)

preamblePaths <- list(modulePath = 'modules',
                      inputPath = "inputs",
                      cachePath = 'cache/preambleCache',
                      outputPath = 'outputs')

dataPrepPaths <- preamblePaths
dataPrepPaths$cachePath <- "cache/dataPrepCache"

#some of this will end up being cloudCache, I believe...
dynamicPaths <-  preamblePaths
dynamicPaths$cachePath <- 'cache/simCache'
