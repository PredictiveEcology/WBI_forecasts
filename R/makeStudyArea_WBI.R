#### Prep study-area for posthoc ####

makeStudyArea <- function(studyAreaName){

  studyAreaNameLong <- switch(studyAreaName,
                              AB = "Alberta",
                              BC = "British Columbia",
                              SK = "Saskatchewan",
                              MB = "Manitoba",
                              NT = "Northwest Territories & Nunavut",
                              NU = "Northwest Territories & Nunavut",
                              YT = "Yukon",
                              RIA = "RIA")

provs <- c("British Columbia", "Alberta", "Saskatchewan", "Manitoba")
terrs <- c("Yukon", "Northwest Territories", "Nunavut")
WB <- c(provs, terrs)

bcrzip <- "https://www.birdscanada.org/download/gislab/bcr_terrestrial_shape.zip"

targetCRS <- paste("+proj=lcc +lat_1=49 +lat_2=77 +lat_0=0 +lon_0=-95",
                   "+x_0=0 +y_0=0 +units=m +no_defs +ellps=GRS80 +towgs84=0,0,0")

bcrshp <- Cache(prepInputs,
                url = bcrzip,
                destinationPath = Paths[["inputPath"]],
                targetCRS = targetCRS,
                fun = "sf::st_read")

if (packageVersion("reproducible") >= "1.2.5") {
  fn1 <- function(x) {
    x <- readRDS(x)
    x <- st_as_sf(x)
    st_transform(x, targetCRS)
  }
} else {
  fn1 <- "readRDS"
}
canProvs <- Cache(prepInputs,
                  "GADM",
                  fun = fn1,
                  dlFun = "raster::getData",
                  country = "CAN", level = 1, path = Paths[["inputPath"]],
                  targetFile = "gadm36_CAN_1_sp.rds", ## TODO: this will change as GADM data update
                  destinationPath = Paths[["inputPath"]])

if (packageVersion("reproducible") < "1.2.5") {
  canProvs <- st_as_sf(canProvs) %>%
    st_transform(., targetCRS)
}

bcrWB <- bcrshp[bcrshp$BCR %in% c(4, 6:8), ]
provsWB <- canProvs[canProvs$NAME_1 %in% WB, ]

WBstudyArea <- Cache(postProcess, provsWB, studyArea = bcrWB, useSAcrs = TRUE,
                         filename2 = NULL, overwrite = TRUE) %>%
  as_Spatial(.)

if (grepl("RIA", studyAreaName)) {
  studyAreaUrl <- "https://drive.google.com/file/d/1LxacDOobTrRUppamkGgVAUFIxNT4iiHU/"
  ## originally, I thought this could be defined after the IF clause as Eliot suggested.
  ## But if RIA SA = SAL, or RTM = RTML, it falls apart.
  studyArea <- Cache(prepInputs, url = studyAreaUrl,
                         destinationPath = Paths[["inputPath"]],
                         userTags = c("studyArea", cacheTags)) %>%
    sf::st_as_sf(.) %>%
    .[.$TSA_NUMBER %in% c("40", "08", "41", "24", "16"),] %>%
    sf::st_buffer(., 0) %>%
    sf::as_Spatial(.) %>%
    raster::aggregate(.)
} else if (grepl("NT|NU", studyAreaName)) {
  ## NOTE: run NT and NU together!
  message("NWT and NU will both be run together as a single study area.")
  studyArea <- WBstudyArea[WBstudyArea$NAME_1 %in% c("Northwest Territories", "Nunavut"), ]
} else {
  studyArea <- WBstudyArea[WBstudyArea$NAME_1 == studyAreaNameLong, ]
}

studyArea <- spTransform(studyArea, targetCRS)

qs::qsave(studyArea, file = file.path(Paths[["inputPath"]],
                                      paste0(studyAreaName, "_SA.qs")))

return(studyArea)
}
