library("googledrive")
library("raster")
library("SpaDES.core")

provs <- c("AB", "BC", "MB", "NT", "SK", "YT")
RTMs <- lapply(provs, function(p) {
  outPath = file.path("outputs", p)
  outPath2 = file.path(outPath, "postprocess")
  if (!dir.exists(outPath2)) dir.create(outPath2)
  foo = SpaDES.core::loadSimList(file.path(outPath, paste0("simOutPreamble_", p, "_CanESM5_370.qs")))
  r = writeRaster(foo$rasterToMatchReporting, file.path(outPath2, paste0("rasterToMatch_", p, ".tif")), overwrite = TRUE)
  filename(r)
})

lapply(RTMs, drive_put, path = as_id("18QhXmli0lHWNF_0Qjlvjy-Y2O1rN0PpP"))

