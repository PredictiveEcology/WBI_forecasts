checkBirdsAvailable_WBI <- function(returnOnlyList = FALSE,
                                    notInclude = NULL,
                                    useRefit = NULL,
                                    refitFolder = NULL,
                                    predFolder = NULL,
                                    whichRun = "run01"){

  # This information came from the Advisory Committee
  # per email on  Jan 22, 2022
  # from Sam Hache, copying
  # Peter, Teegan, Steven, Logan, Tara, Andrea, Junior, Alex, Eliot and me.
  # Diana was brought up to speed on Feb 15th 2022 via meeting (during SpaDES
  # Module meeting slot)

  if (is.null(refitFolder))
    refitFolder <- "1hVSIzyyq6ueAF5hmtWG-fsFbm8KAmzQn"
  if (is.null(predFolder))
    predFolder <- "1GWrdkozelFCabAO4dKRAwZHb3hVEeyS8"
      # "16cqiZRE9H2SoAaYfgUYQz6TT-0yhLN2i" # Folder without the real models. Only assessment
  if (is.null(notInclude))
    notInclude <- c("HETH", "MAWR")
  if (is.null(useRefit))
    useRefit <- c("LALO", "ATTW", "TOSO")

  birdsPred <- data.table::data.table(googledrive::drive_ls(path = as_id(predFolder), recursive = FALSE))
  birdsPred <- birdsPred[, c("name", "id")]
  replic <- switch(EXPR = whichRun,
                     run01 = "-1.qRData",
                     run02 = "-2.qRData",
                     run03 = "-3.qRData",
                     run04 = "-4.qRData",
                     run05 = "-5.qRData",
                     run06 = "-6.qRData",
                     run07 = "-7.qRData",
                     run08 = "-8.qRData",
                     run09 = "-9.qRData",
                     run10 = "-10.qRData")

  birdsPred[, Model := paste0("ALL", replic)] # This is the common name to identify the model

  if (returnOnlyList){
    return(birdsPred[["name"]])
  }

  birdsPred <- birdsPred[!name %in% c(notInclude, useRefit), ]
  birdsRefit <- data.table::data.table(googledrive::drive_ls(path = as_id(refitFolder), recursive = FALSE))
  birdsRefit <- birdsRefit[name %in% useRefit, c("name", "id")]
  birdsRefit[, Model := "refit10"]

  finalDT <- rbind(birdsPred, birdsRefit)
  names(finalDT) <- c("Species", "folderID", "modelUsed")
  setkey(finalDT, "Species")

  message(paste0("Returning landbird list with corrected url. Following ",
                   "birds were: \n",
                   "Not included: ", paste(notInclude, collapse = ", "), "\n",
                   "Included using refit: ", paste(useRefit, collapse = ", ")))

    return(finalDT)

}
