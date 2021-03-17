Require::Require("googledrive")

filesToUpload <- c("fireSense_SpreadFit_veg_coeffs.txt",
                   "figures/PCAcoeffLoadings.png",
                   "figures/spreadFit_coeffs.png")

gdrive_ID <- switch(studyAreaName,
                    AB = "1Y3bMg0HgETSUni86aYCx5NbA2-FSPqqe",
                    BC = "1-6KCdlNmIo2pupGpUSrWPKz8G9t4KLb2",
                    MB = "1-bSOnptvNm0uxv3BO3FD_jLs534vWkYL",
                    NT = "1A4OJCDzGxVzdhNtuaV2xbjemoSUUm8fk",
                    NU = "1A4OJCDzGxVzdhNtuaV2xbjemoSUUm8fk", ## same as NT
                    RIA = "1jKtORmoJBJh6SNLqt7pbtcMY6Lb53X2S",
                    SK = "1-yVUS0WlOM3sAxDkaQjluRtv1Y19okYQ",
                    YT = "1M3jUbrZMIIfrL7-QQCItQ2T_vteBTeAj")
lapply(filesToUpload, function(f) {
  drive_upload(file.path("outputs", studyAreaName, f), as_id(gdrive_ID), overwrite = TRUE)
}) ## TODO: upload first time, update subsequently.
