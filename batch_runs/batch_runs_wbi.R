#source("batch_runs/batch_runs_CanESM5_AB.R")
#source("batch_runs/batch_runs_CNRM-ESM2-1_AB.R")

#source("batch_runs/batch_runs_CanESM5_BC.R")
#source("batch_runs/batch_runs_CNRM-ESM2-1_BC.R")

#source("batch_runs/batch_runs_CanESM5_SK.R")
#source("batch_runs/batch_runs_CNRM-ESM2-1_SK.R")

#source("batch_runs/batch_runs_CanESM5_MB.R")
#source("batch_runs/batch_runs_CNRM-ESM2-1_MB.R")

source("batch_runs/batch_runs_CanESM5_YT.R") ## pseudotsuga
source("batch_runs/batch_runs_CNRM-ESM2-1_YT.R") ## pseudotsuga

source("batch_runs/batch_runs_CanESM5_NT.R") ## pseudotsuga
source("batch_runs/batch_runs_CNRM-ESM2-1_NT.R") ## psedotsuga


files2upload <- c(
  list.files("outputs", "(CanESM5|CNRM-ESM2-1).*[.]tar.gz$", full.names = TRUE)
)
lapply(files2upload, function(tarball) {
  retry(quote(drive_put(media = tarball, path = unique(as_id(gid_results)), name = basename(tarball))),
        retries = 5, exponentialDecayBase = 2)
})
