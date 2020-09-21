getPreambleObjects <- function(studyArea) {
  if (studyArea == 'BC') {

    #studyArea = 5 TSAs for now - not sure we need em all, they aren't all boreal
    #TSAs 08 and 41 are not harvested nearly as much as 8 and 16, and to a lesser extent, 40
    studyArea <- prepInputs(url = 'https://drive.google.com/file/d/1LxacDOobTrRUppamkGgVAUFIxNT4iiHU/view?usp=sharing',
                            destinationPath = paths$inputPath,
                            overwrite = TRUE,
                            useCache = TRUE) %>%
      sf::st_as_sf(.) %>%
      .[.$TSA_NUMBER %in% c('40', '08', '41', '24', '16'),] %>%
      sf::as_Spatial(.)
    studyAreaLarge <- studyArea

    rasterToMatch <- prepInputsLCC(studyArea = studyArea,
                                   destinationPath = preamblePaths$inputPath,
                                   cachePath = preamblePaths$cachePath,
                                   filename2 = 'BC_rtm.tif',
                                   overwrite = TRUE,
                                   useCache = TRUE
                                   )
    rasterToMatchLarge = rasterToMatch

    #get species objects
    #

    return(list(studyArea = studyArea,
                studyAreaLarge = studyAreaLarge
                rasterToMatch = rasterToMatch
                rasterToMatchLarge = rasterToMatchLarge
                spp_Equiv = sppEquivalencies_CA,
                sppEquivCol = sppEquivCol,
                historicalMDC =
                projectedMDC = ))
  } else {
    stop("no other study areas at the moment :( ")
  }
}
