birdPredictionCoresCalc_WBI <- function(birdSpecies = NULL,
                                    availableCores = parallel::detectCores()-3,
                                    availableRAM = as.numeric(system("awk '/MemAvailable/ {print $2}' /proc/meminfo", intern=TRUE))*0.00000095367432,
                                    sizeGbEachProcess = 10){ # if TRUE, return number of cores, FALSE
  # returns IP of workers
  if (is.null(birdSpecies))
    stop("Please provide a vector of the bird species")

  tryCatch({
    nGroups <- 1
    cores <- .calcRAMorCores(availableCores = availableCores,
                                         availableRAM = availableRAM,
                                         nProcess = length(birdSpecies), # Species or parameters
                                         baseProcess = "RAM", # can also be "RAM" when that is the limiting factor!
                                         sizeGbEachProcess = sizeGbEachProcess)
    return(list(cores = cores,
                birdSpecies = list("Group1" = birdSpecies)))
  }, error = function(e) {
    divideBirdsSp <- TRUE
    while (divideBirdsSp){
      print(paste0("Not enough RAM for ", nGroups,
                   " group(s). Trying ", nGroups+1, " groups..."))
      nGroups <- nGroups + 1
      # Divide the groups based on nGroups
      birdSpeciesG <- chunk(toDivide = birdSpecies, nGroups = nGroups)
      names(birdSpeciesG) <- paste0("Group", 1:nGroups)
      largest <- max(sapply(birdSpeciesG, length))
      tryCatch({
        cores <- .calcRAMorCores(availableCores = availableCores,
                                    availableRAM = availableRAM,
                                    nProcess = largest, # Species or parameters
                                    baseProcess = "RAM", # can also be "RAM" when that is the limiting factor!
                                    sizeGbEachProcess = sizeGbEachProcess)
        return(list(cores = cores,
                    birdSpecies = birdSpeciesG))
      }, error = function(e){
        return(NULL)
      })
    }
  }
  )
}

chunk <- function(toDivide, nGroups){
  dd <- split(toDivide, factor(sort(rank(toDivide)%%nGroups)))
  return(dd)
}

.calcRAMorCores <- function(availableCores = parallel::detectCores()-3,
                               availableRAM = as.numeric(system("awk '/MemAvailable/ {print $2}' /proc/meminfo", intern=TRUE))*0.00000095367432,
                               nProcess = 8,
                               baseProcess = "cores", # can also be "RAM" when that is the limiting factor!
                               internalProcesses = 10,
                               sizeGbEachProcess = 35){

    NP <- ifelse(baseProcess == "cores",
                 nProcess * internalProcesses,
                 nProcess * sizeGbEachProcess)

  procs <- .calcProc(NP = NP,
                 proc = baseProcess,
                 nProcess = nProcess,
                 sizeGbEachProcess = sizeGbEachProcess,
                 availableCores = availableCores,
                 availableRAM)
  return(procs)
}

.calcProc <- function(NP,
                    proc,
                    nProcess,
                    sizeGbEachProcess,
                    availableCores,
                    availableRAM) {

  if (proc == "cores"){
    if (availableCores < NP)
      stop("Not enough cores")
  } else {
    if (availableRAM < NP)
      stop("Not enough RAM")
  }

  if (proc == "RAM"){
    # find the number of cores for the amount of
    # RAM needed
    ncoresVector <- optimalClusterNumGeneralized(memRequiredMB = sizeGbEachProcess,
                                              maxNumClusters = availableCores,
                                              NumCoresAvailable = availableCores,
                                              availMem = availableRAM)
    coresByRAM <- ncoresVector
    NP <- min(coresByRAM, nProcess)
  }
}

optimalClusterNumGeneralized <- function(memRequiredMB = 500,
                                         maxNumClusters = parallel::detectCores(),
                                         NumCoresAvailable = parallel::detectCores(),
                                         availMem = pemisc::availableMemory()/1e+06){
  if (maxNumClusters > 0) {
    if (!is.null(availMem)) {
      numClusters <- floor(min(NumCoresAvailable,
                               availMem/memRequiredMB))
    }
    else {
      message("Unable to estimate available memory. Returning 1 cluster.")
      numClusters <- 1
    }
    numClusters <- min(maxNumClusters, numClusters, NumCoresAvailable)
  }
  else {
    numClusters <- 1
  }
  return(numClusters)
}

