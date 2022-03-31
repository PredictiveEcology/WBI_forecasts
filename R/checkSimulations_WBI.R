checkSimulations_WBI <- function(outFolder = "/home/tmichele/GitHub/WBI_forecasts/outputs/",
                                 returnAll = FALSE, sleep30 = TRUE){

  Require::Require("tictoc")

  grepMulti <- function(x, patterns, unwanted = NULL) {
    rescued <- sapply(x, function(fun) all(sapply(X = patterns, FUN = grepl, fun)))
    recovered <- x[rescued]
    if (!is.null(unwanted)){
      discard <- sapply(recovered, function(fun) all(sapply(X = unwanted, FUN = grepl, fun)))
      afterFiltering <- recovered[!discard]
      return(afterFiltering)
    } else {
      return(recovered)
    }
  }
  percCompleted <- 0
  while (percCompleted < 99.9) {
   if (sleep30) Sys.sleep(30*60)
  rp <- c(paste0("run0", 1:5))
  ys <- c(2011, 2031, 2051, 2071, 2091)
  ps <- c("AB", "BC", "SK", "MB", "YT", "NT")
  ss <- c("SSP370", "SSP585")
  cs <- c("CanESM5", "CNRM-ESM2-1")
  bs <- c("ALFL", "AMCR", "AMGO", "AMRE", "AMRO", "ATSP", "ATTW", "BAOR",
          "BARS", "BAWW", "BBCU", "BBMA", "BBWA", "BBWO", "BCCH", "BEKI",
          "BHCO", "BHVI", "BLBW", "BLJA", "BLPW", "BOBO", "BOCH", "BOWA",
          "BRBL", "BRCR", "BTNW", "CAWA", "CCSP", "CEDW", "CHSP", "CMWA",
          "COGR", "CONW", "CORA", "COYE", "CSWA", "DEJU", "DOWO", "EAKI",
          "EAPH", "EUST", "EVGR", "FOSP", "GCFL", "GCKI", "GCSP", "GCTH",
          "GRAJ", "GRCA", "GRYE", "HAFL", "HAWO", "HOLA", "HOSP", "HOWR",
          "KILL", "LALO", "LCSP", "LEFL", "LEYE", "LISP", "MAWA", "MODO",
          "MOWA", "NAWA", "NOFL", "NOWA", "OCWA", "OSFL", "OVEN", "PAWA",
          "PHVI", "PIGR", "PISI", "PIWO", "PUFI", "RBGR", "RBNU", "RCKI",
          "RECR", "REVI", "RUBL", "RUGR", "RWBL", "SAVS", "SEWR", "SOSA",
          "SOSP", "SPSA", "SWSP", "SWTH", "TEWA", "TOSO", "TOWA", "TRES",
          "VATH", "VEER", "VESP", "WAVI", "WBNU", "WCSP", "WETA", "WEWP",
          "WIPT", "WISN", "WIWA", "WIWR", "WTSP", "WWCR", "YBFL", "YBSA",
          "YEWA", "YHBL", "YRWA")

  # Structure: "ps_cs_ss_rp_predicted_bs_Yearys.tif"
expectedFiles <- data.table::data.table(expand.grid(ps, "_", cs, "_", ss, "_", rp, "_predicted_", bs, paste0("_Years",
                                                               ys, ".tif")))
expectedFiles[, fileName := paste0(Var1, Var2, Var3, Var4, Var5,
                                   Var6, Var7, Var8, Var9, Var10)]
expectedFiles <- expectedFiles[["fileName"]]
existingFiles   <- na.omit(unlist(lapply(rp, function(RP){
  tb2 <- lapply(cs, function(CS){
     tb3 <-  lapply(ss, function(SS){
        tb4 <- lapply(ps, function(P){
              fls <- list.files(paste0(outFolder, P, "/posthoc/"))
              if (length(fls) == 0) return(NA) else {
                allFls <- grepMulti(fls,
                                    patterns = c(RP, CS, SS, P),
                                    unwanted = ".aux.xml")
                return(allFls)
              }
            })
        tb4unlist <- unlist(tb4)
        return(tb4unlist)
      })
     tb3unlist <- unlist(tb3)
     return(tb3unlist)
    })
  tb2unlist <- unlist(tb2)
  return(tb2unlist)
  })))
percCompleted <- 100*(length(existingFiles)/length(expectedFiles))
print(paste0("Completed: ", round(percCompleted, 2), "%: ", format(Sys.time(), "%A %B %d %X %Y")))
a <- strsplit(existingFiles, split = "_predicted")
b <- unique(unlist(lapply(X = a, FUN = function(aa) return(aa[1]))))
if (returnAll) return(b)
  }
}
sims <- sort(checkSimulations_WBI(returnAll = TRUE, sleep30 = FALSE))
print(sims)

