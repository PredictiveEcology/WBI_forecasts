moduleDir <- "modules"

source("01-packages.R")

source("02-init.R")
source("03-paths.R")
source("04-options.R")
source("05-google-ids.R")

wd <- getwd()

## 2001
dirStacks2001 <- checkPath("/mnt/wbi_data/BAM/stacks2001", create = TRUE)
setwd(dirStacks2001)
stacks2001 <- drive_ls(as_id("1eiuReWmJ0rUy2B2H-JiFEUtDwK4M4IgM"))
lapply(stacks2001$id, function(x) {
  drive_download(x)
})
setwd(wd)

## 2011
dirStacks2011 <- checkPath("/mnt/wbi_data/BAM/stacks2011", create = TRUE)
setwd(dirStacks2011)
stacks2011 <- drive_ls(as_id("1RPXqgq-M1mOKMYzUnVSpw_6sjJ4m07dj"))
lapply(stacks2011$id, function(x) {
  drive_download(x)
})
setwd(wd)
