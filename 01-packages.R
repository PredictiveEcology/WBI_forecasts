if (!exists("pkgDir")) {
  pkgDir <- file.path("packages", version$platform, paste0(version$major, ".",
                                                           strsplit(version$minor, "[.]")[[1]][1]))
}

if (!dir.exists(pkgDir)) {
  dir.create(pkgDir, recursive = TRUE)
}

.libPaths(pkgDir)

if (!require("Require", quietly = TRUE)) {
  install.packages("Require")
  library(Require)
}

Require("PredictiveEcology/SpaDES.install@development")
installSpaDES()

if (FALSE) {
  .spatialPkgs <- c("lwgeom", "rgdal", "rgeos", "sf", "sp", "raster", "terra")
  installSpatialPackages()
  #install.packages(c("raster", "terra"), repos = "https://rspatial.r-universe.dev")
  sf::sf_extSoftVersion() ## want GEOS 3.9.0, GDAL 3.2.1, PROJ 7.2.1
}

out <- makeSureAllPackagesInstalled(modulePath = moduleDir)

Require(c("RCurl", "RPostgres", "XML"), require = FALSE)

## NOTE: always load packages LAST, after installation above;
##       ensure plyr loaded before dplyr or there will be problems
Require(c("data.table", "plyr", "pryr",
          "PredictiveEcology/LandR@development", ## TODO: workaround weird raster/sf method problem
          "PredictiveEcology/SpaDES.core@development",
          "archive", "config", "googledrive", "httr", "slackr"), upgrade = FALSE)