
fSsimDataPrep$fireSense_escapeCovariates <- as.data.table(fSsimDataPrep$fireSense_escapeCovariates)
fSsimDataPrep$fireSense_annualSpreadFitCovariates <- lapply(fSsimDataPrep$fireSense_annualSpreadFitCovariates, as.data.table)
fSsimDataPrep$fireBufferedListDT <- lapply(fSsimDataPrep$fireBufferedListDT, as.data.table)
fSsimDataPrep$fireSense_nonAnnualSpreadFitCovariates$year2011_year2012_year2013_year2014_year2015_year2016_year2017_year2018_year2019 <- as.data.table(fSsimDataPrep$fireSense_nonAnnualSpreadFitCovariates$year2011_year2012_year2013_year2014_year2015_year2016_year2017_year2018_year2019)
fSsimDataPrep$fireSense_nonAnnualSpreadFitCovariates$year2002_year2003_year2004_year2005_year2006_year2007_year2008_year2009_year2010 <- as.data.table(fSsimDataPrep$fireSense_nonAnnualSpreadFitCovariates$year2002_year2003_year2004_year2005_year2006_year2007_year2008_year2009_year2010)
fSsimDataPrep$cohortData2011 <- as.data.table(fSsimDataPrep$cohortData2011)
fSsimDataPrep$cohortData2001 <- as.data.table(fSsimDataPrep$cohortData2001)
fSsimDataPrep$fireSense_ignitionCovariates <- as.data.table(fSsimDataPrep$fireSense_ignitionCovariates)
fSsimDataPrep$landcoverDT <- as.data.table(fSsimDataPrep$landcoverDT)
fSsimDataPrep$terrainDT <- as.data.table(fSsimDataPrep$terrainDT)
fSsimDataPrep$sppEquiv <- as.data.table(fSsimDataPrep$sppEquiv)
#note preamble sppEquivgain..


biomassMaps2011$cohortData <- as.data.table(biomassMaps2011$cohortData)
biomassMaps2011$pixelFateDT <- as.data.table(biomassMaps2011$pixelFateDT)
biomassMaps2011$species <- as.data.table(biomassMaps2001$species)
biomassMaps2011$speciesEcoregion <- as.data.table(biomassMaps2011$speciesEcoregion)
biomassMaps2011$sppEquiv <- as.data.table(biomassMaps2011$sppEquiv)
biomassMaps2011$sufficientLight <- as.data.frame(biomassMaps2011$sufficientLight)
