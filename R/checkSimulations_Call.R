# Simulations ready

# MAPS and plots
# OSFL, CAWA, RUBL

# Summaries: all birds
#
# sims <- sort(checkSimulations_WBI(BirdSpecies = c("OSFL", "CAWA", "RUBL"),
#                                   returnAll = TRUE, sleep30 = FALSE))
# print(sims)
#
# sims2 <- sort(checkSimulations_WBI2(BirdSpecies = c("OSFL", "CAWA", "RUBL"),
#                                   returnAll = TRUE, sleep30 = FALSE))
#
# CAWA <- sims2[grepl(x = sims2, pattern = "CAWA")]
# OSFL <- sims2[grepl(x = sims2, pattern = "OSFL")]
# RUBL <- sims2[grepl(x = sims2, pattern = "RUBL")]
# # 5 Points in time * 5 runs * 2 climate models * 2 SSP * 6 provinces
# 5*5*2*2*6
#
# Require::Require("data.table")
#
# sims3 <- sort(checkSimulations_WBI2(BirdSpecies = c("BCCH"),
#                                     returnAll = TRUE, sleep30 = FALSE))
#
bds <- c("ALFL", "AMCR", "AMGO", "AMRE", "AMRO", "ATSP", "ATTW", "BAOR",
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
Require::Require("data.table")
# bds <- c("BBMA", "BCCH", "BLJA", "BOCH", "CCSP", "CONW", "CSWA", "DEJU",
#             "EVGR", "GCTH", "GRAJ", "GRCA")

tictoc::tic("Total Elapsed Time: ")

sims4 <- sort(checkSimulations_WBI2(BirdSpecies = bds, whatToReturn = "available"))

completedBirds <- rbindlist(lapply(bds, function(BIRD){
  BD <- sims4[grepl(x = sims4, pattern = BIRD)]
  comp <- 100*(length(BD)/600) # How many divided by expected
  DT <- data.table(Species = BIRD,
                   Completion = comp)
  return(DT)
}))
toc()
completedBirds

