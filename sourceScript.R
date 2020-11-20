#sourceScript
studyAreaName <- 'RIA'
#Spread expects a character arg for cloudFolderID, but Cache accepts a dribble.
#if using the character, we need to set the reproducible.cloudFolderID option. Not sure which is better
library(googledrive)
CloudFolderID <- drive_mkdir(name = paste0('spreadFit_', studyAreaName),
                             path = as_id('https://drive.google.com/drive/folders/18aXrRWI3sc6WUG56qaTaa8YXMlCWFS6m?usp=sharing'))

source('01-init.R')
source('02-packages.R')
source('03-paths.R')
source('04-options.R')
source('05-objects.R')
source('06-studyArea.R')
source('07-dataPrep.R')
source('08-spreadFit.R') #this is out of order, for now
