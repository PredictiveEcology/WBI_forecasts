Require("PredictiveEcology/SpaDES.install@development")

installSpaDES()
installSpatialPackages()
#install.packages(c("raster", "terra"), repos = "https://rspatial.r-universe.dev")
sf::sf_extSoftVersion() ## want GEOS 3.9.0, GDAL 3.2.1, PROJ 7.2.1

Require(c("data.table", "plyr", "pryr")) ## ensure plyr loaded before dplyr or there will be problems
Require("RCurl", require = FALSE)
Require(c("archive", "slackr"), upgrade = FALSE)

out <- makeSureAllPackagesInstalled(modulePath = defaultPaths$modulePath)
