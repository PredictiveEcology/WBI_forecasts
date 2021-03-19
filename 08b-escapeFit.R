do.call(setPaths, escapeFitPaths)

escapeFitParams <- list(
  fireSense_EscapeFit = list(
    fireSense_escapeFormula = fSsimDataPrep$fireSense_escapeFormula
  )
)

escapeFitObjects <- list(
  fireSense_escapeCovariates = fSsimDataPrep$fireSense_escapeCovariates
)

#descapeOut <- file.path(Paths$outputPath, paste0("escapeOut_", studyAreaName)) %>%
#  checkPath(create = TRUE)
#aescapeOut <- paste0(descapeOut, ".7z")
fescapeOut <- file.path(Paths$outputPath, paste0("escapeOut_", studyAreaName, ".qs"))
if (isTRUE(usePrerun)) {
  if (!file.exists(fescapeOut)) {
    googledrive::drive_download(file = as_id(gdriveSims[["escapeOut"]]), path = fescapeOut)
  }
  #if (!dir.exists(descapeOut) || length(list.files(descapeOut)) == 0) {
  #  googledrive::drive_download(file = as_id(gdriveSims[["escapeOutArchive"]]), path = aescapeOut)
  #  archive::archive_extract(basename(aescapeOut), dirname(aescapeOut))
  #}
  escapeOut <- loadSimList(fescapeOut)
} else {
  escapeOut <- simInitAndSpades(
    times = list(start = 0, end = 1),
    # ignitionSim <- simInit(times = list(start = 0, end = 1),
    params = escapeFitParams,
    modules = "fireSense_EscapeFit",
    paths = escapeFitPaths,
    objects = escapeFitObjects
  )
  saveSimList(
    sim = escapeOut,
    filename = fescapeOut,
    #filebackedDir = descapeOut,
    fileBackend = 2
  )
  #archive::archive_write_dir(archive = aescapeOut, dir = descapeOut)
  if (isTRUE(firstRun)) {
    googledrive::drive_put(media = fescapeOut, path = gdriveURL, name = basename(fescapeOut), verbose = TRUE)
    #googledrive::drive_put(media = aescapeOut, path = gdriveURL, name = basename(aescapeOut), verbose = TRUE)
  } else {
    googledrive::drive_update(file = as_id(gdriveSims[["escapeOut"]]), media = fescapeOut)
    #googledrive::drive_update(file = as_id(gdriveSims[["escapeOutArchive"]]), media = aescapeOut)
  }
}
