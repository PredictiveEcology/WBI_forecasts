#for running FireSense somewhere other than NWT
library(SpaDES)
library(raster)
library(LandR)
library(data.table)
library(magrittr)
source("generateSppEquiv.R")

scratchdir <- file.path("/mnt/scratch/ieddy")


googledrive::drive_auth(email = "ianmseddy@gmail.com", use_oob = TRUE)

setPaths(modulePath = file.path('/home/ieddy/git'), 
         inputPath = "Inputs", 
         cachePath = 'Cache',
         outputPath = 'Outputs')

paths <- getPaths()
times <- list(start = 0, end = 10)

#this is Ft St John but might as well run RIA, in which case SAL = SA
studyArea <- prepInputs(url = 'https://drive.google.com/file/d/1LxacDOobTrRUppamkGgVAUFIxNT4iiHU/view?usp=sharing',
                                     destinationPath = paths$inputPath,
                                     overwrite = TRUE,
                                     useCache = TRUE) %>%
  sf::st_as_sf(.) %>%
  .[.$TSA_NUMBER %in% c('40'),] %>%
  sf::as_Spatial(.)

studyAreaLarge <- prepInputs(url = 'https://drive.google.com/file/d/1LxacDOobTrRUppamkGgVAUFIxNT4iiHU/view?usp=sharing',
                             destinationPath = paths$inputPath,
                             overwrite = TRUE,
                             useCache = 'overwrite', 
                             FUN = 'sf::st_read') %>%
  sf::st_as_sf(.)
studyAreaLarge <- studyAreaLarge[studyAreaLarge$TSA_NUMBER %in% c('08', '16', '24', '40', '41'),]
if (length(unique(sf::st_geometry_type(studyAreaLarge))) > 1)  ## convert sfc to sf if needed
  sf::st_geometry(studyAreaLarge) <- sf::st_collection_extract(x = sf::st_geometry(studyAreaLarge), type = "POLYGON")
# studyAreaLarge <- sf::as_Spatial(studyAreaLarge)
studyAreaLarge <- sf::st_buffer(studyAreaLarge, 0) %>%
  sf::as_Spatial(.) %>% 
  raster::aggregate(.) %>% 
  sf::st_as_sf(.)
studyAreaLarge$studyArea <- "5TSA"
studyAreaLarge <- sf::as_Spatial(studyAreaLarge)

rasterToMatchLarge <- LandR::prepInputsLCC(destinationPath = paths$inputPath, 
                                           studyArea = studyAreaLarge, 
                                           filename2 = file.path(paths$inputPath, 'rasterToMatchLarge.tif'),
                                           overwrite = TRUE)

rasterToMatch <- LandR::prepInputsLCC(destinationPath = paths$inputPath, 
                                      studyArea = studyArea, 
                                      overwrite = TRUE,
                                      filename2 = file.path(paths$inputPath, 'rasterToMatch.tif'),
                                      useCache = TRUE)
studyArea <- spTransform(studyArea, CRS = crs(rasterToMatch))
studyAreaLarge <- spTransform(studyAreaLarge, CRS = crs(rasterToMatchLarge))

studyAreaName <- 'FtStJohn'

sppColorVect <- sppColors(sppEquivalencies_CA, 'RIA',
                              newVals = "Mixed", palette = "Accent")

#projected MDC - you don't need to actually supply the objects currently - need to fix this
MDC06 <- prepInputs(url = 'https://drive.google.com/file/d/1ErQhfE5IYGRV_2voeb5iStWt_h2D5cV3/view?usp=sharing',
                    destinationPath = paths$inputPath,
                    rasterToMatch = rasterToMatch,
                    overwrite = TRUE,
                    useCache = TRUE,
                    fun = 'raster::stack',
                    userTags = c("projMDC"))

MDC <- prepInputs(url = 'https://drive.google.com/file/d/1DtB2_Gftl4R7T4yM9-mjVCCXF5nBXKqD/view?usp=sharing',
                  destinationPath = paths$inputPath,
                  rasterToMatch = rasterToMatch,
                  overwrite = TRUE,
                  useCache = TRUE,
                  fun = 'raster::stack',
                  userTags = c("histMDC"))


source("generateFireSenseInputs.R")

#fireSense DEoptim params
lowerParams <- c(-16, -16, -16, -16, -16, -16)
upperParams <- c(32, 32, 32, 32, 32, 32)
lower <- c(0.22, 0.001, lowerParams)
upper <- c(0.29, 10, upperParams)


parameters <- list(
  fireSense_dataPrep = list(
    'whichModulesToPrepare' = c("fireSense_SpreadFit"), 
    'train' = FALSE,
    'projectedClimateFilePath' = 'Inputs/CCSM4RCP45.zip',
    'historicalClimateDataInputPath' = 'Inputs/historicalMDC.zip',
    'sppEquivCol' = 'RIA',
    'useCentroids' = TRUE),
  fireSense_SpreadFit = list(
    'formula' = formula(~ 0 + weather + class1 + class2 + class3 + class4 + class5),
    'lower' = lower,
    'upper' = upper, 
    'useCentroids' = TRUE
    )
  #, module1 = list(param1 = value1, param2 = value2),
  #, module2 = list(param1 = value1, param2 = value2)
)


modules <- list("fireSense_dataPrep", 'fireSense_SpreadFit')

#this wont' work with the shitty connection
# testPolys <- fireSenseUtils::getFirePolygons(pathInputs = 'Inputs', years = 1991:2017, studyArea = studyArea)

#this wont' work because the download failed...not sure why...

firePolys <- prepInputs(url = 'https://drive.google.com/file/d/1XWCuA8vIKb5d_rXZUygjyWTG0dJlE82x/view?usp=sharing', 
                        destinationPath = 'Inputs', 
                        studyArea = studyArea, 
                        useCache = TRUE, overwrite = TRUE, 
                        userTags = ("ftStJohn_firePolys"))
firePolys <- lapply(1991:2017, FUN = function(year, spdf = firePolys){
  fireYear <- spdf[spdf$YEAR == year,]
})
names(firePolys) <- paste0('year', 1991:2017)
firePolys['year2001'] <- NULL #this is necessary

#this shouldn't be necessary, need to figure out what is happening wtih download

objects <- list('cohortData2001' = biomassMaps2001$cohortData,
                'cohortData2011' = biomassMaps2011$cohortData,
                'pixelGroupMap2001' = biomassMaps2001$pixelGroupMap,
                'pixelGroupMap2011' = biomassMaps2011$pixelGroupMap,
                'rasterToMatch' = rasterToMatch,
                'firePolys' = firePolys,
                'studyArea' = studyArea,
                'MDC' = MDC,
                'MDC06' = MDC06,
                'sppEquiv' = sppEquivalencies_CA,
                'usrEmail' = 'ianmseddy@gmail.com')
outputs <- list()

options(
  rasterTmpDir = scratchdir
)


devtools::load_all("../git/fireSenseUtils")
mySim <- simInit(times = times, params = parameters, modules = modules,
                 objects = objects, paths = paths, loadOrder = unlist(modules))
.gc()

mySimOut <- spades(mySim)                 

