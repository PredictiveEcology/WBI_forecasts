do.call(setPaths, escapeFitPaths)

escapeFitParams <- list(
  fireSense_EscapeFit = list(
    fireSense_escapeFormula = simDataPrep$fireSense_escapeFormula
  )
)

escapeFitObjects <- list(
  fireSense_escapeCovariates = simDataPrep$fireSense_escapeCovariates
)

escapeOut <- simInitAndSpades(times = list(start = 0, end = 1),
                                # ignitionSim <- simInit(times = list(start = 0, end = 1),
                                params = escapeFitParams,
                                modules = "fireSense_EscapeFit",
                                paths = escapeFitPaths,
                                objects = escapeFitObjects)
