.spatialPkgs <- c("lwgeom", "rgdal", "rgeos", "sf", "sp", "raster", "terra")
if (!all(.spatialPkgs %in% installed.packages())) {
  SpaDES.install::installSpatialPackages()
  #install.packages(c("raster", "terra"), repos = "https://rspatial.r-universe.dev")
  sf::sf_extSoftVersion() ## want GEOS 3.9.0, GDAL 3.2.1, PROJ 7.2.1
}

Require(c("data.table", "plyr", "pryr", "SpaDES.core")) ## ensure plyr loaded before dplyr or there will be problems
Require(c("RCurl", "XML"), require = FALSE)
Require(c("archive", "slackr"), upgrade = FALSE)

out <- SpaDES.install::makeSureAllPackagesInstalled(modulePath = defaultPaths$modulePath)
