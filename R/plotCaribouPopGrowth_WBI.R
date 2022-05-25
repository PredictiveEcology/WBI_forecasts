plotCaribouPopGrowth_WBI <- function(currentTime,
                                   endTime,
                                   province,
                                   resultsMainFolder = NULL, # Pass this if outside of module
                                   climateModel = NULL,
                                   predictedCaribou = NULL,
                                   uploadPlots = NULL,
                                   rowsLegend = 2,
                                   reps = paste0("run0", 1:5),
                                   outputFolder,
                                   whichPolysToIgnore = NULL, # Optional to ensure only specific polygons to be plotted
                                   timeSpan = "annual") # Optional = "timeStep" (normally every 10y)
{

  library("Require")
  Require("data.table")
  Require("ggplot2")
  if (any(all(is.null(resultsMainFolder),
              is.null(predictedCaribou)),
          all(!is.null(resultsMainFolder),
              !is.null(predictedCaribou))))
    stop("Please provide either predictedCaribou or resultsMainFolder")

  if (is.null(climateModel)){
    message(crayon::red("climateModel is NULL, default is 'CanESM5_SSP370'"))
    climateModel <- "CanESM5_SSP370"
    # CanESM5_SSP370, CanESM5_SSP585, CNRM-ESM2-1_SSP370, CNRM-ESM2-1_SSP585
  }
  if (!is.null(resultsMainFolder)){
    allcombs <- data.table(expand.grid(climateModel, reps))
    allcombs[, comb := paste0(Var1, "_",Var2)]
    predictedCaribou <- rbindlist(lapply(allcombs[, comb], function(patt){
      tableFileName <- list.files(path = resultsMainFolder,
                                  pattern = paste0("predictedCaribou_Year", currentTime,
                                                   "_", province, "_",
                                                   patt),
                                  full.names = TRUE, recursive = FALSE)
      if (any(!file.exists(tableFileName),
              length(tableFileName) == 0)){
        message(paste0("File ", tableFileName,
                       " doesn't seem to exist!",
                       " Debug"))
        browser()
      }
      tb <- readRDS(tableFileName)
      if (NROW(tb) == 0){
        message(paste0("File ", tableFileName,
                       " is empty.",
                       " Debug"))
        return(NULL)
      }
      if (!is.null(uploadPlots))
        drive_upload(tableFileName, as_id(uploadPlots))

      addedTB <- rbindlist(lapply(names(tb), function(years){
        TB <- tb[[years]]
        climMod <- strsplit(patt, "_run0")[[1]][1]
        replic <- strsplit(patt, "_run0")[[1]][2]
        TB[, c("climateModel", "Replicate", "Year") := list(climMod,
                                                            paste0("run0", replic),
                                                            usefulFuns::substrBoth(years, 4, T))]
        return(TB)
      }))
      return(addedTB)
    }))
  }
  tableAll <- predictedCaribou

  yaxis <- if (timeSpan == "annual") "annualLambda" else "growth"
  yaxisName <- yaxis

  tableAll[, minRib := min(get(paste0(yaxis, "Min"))), by = c("Year", "Herd",
                                                              "climateModel", "femSurvMod_recrMod")]
  tableAll[, maxRib := max(get(paste0(yaxis, "Max"))), by = c("Year", "Herd",
                                                              "climateModel", "femSurvMod_recrMod")]
  tableAll[, paste0("average", yaxis) := mean(get(yaxis)), by = c("Year", "Herd", "climateModel",
                                                                  "femSurvMod_recrMod")]

  if (!is.null(whichPolysToIgnore)){
    tableAll <- tableAll[!Herd %in% whichPolysToIgnore, ]
  }
  yrReady <- lapply(X = unique(tableAll[["area"]]),
                    FUN = function(shp){
                      polyReady <- lapply(X = unique(tableAll[area == shp, femSurvMod_recrMod]),
                                          FUN = function(mod){
                                            message(paste0("Plotting caribou population growth for ", shp,
                                                           " for ", mod))
                                            DT <- tableAll[area == shp & femSurvMod_recrMod == mod, ]
                                            survMod <- strsplit(strsplit(mod, "::")[[1]][1], "_National")[[1]][1]
                                            recMod <- strsplit(strsplit(mod, "::")[[1]][2], "_National")[[1]][1]

                                            tryCatch(quickPlot::clearPlot(), error = function(e){
                                              message(crayon::red("quickPlot::clearPlot() failed"))
                                            })
                                            if (unique(DT[["area"]]) == "metaHeards"){
                                              DT[Herd == "Dehcho North_v2", Herd := "Dehcho North"]
                                              DT[Herd == "Dehcho South_v2", Herd := "Dehcho South"]
                                              DT[, Herd := factor(Herd,
                                                                  levels = c("GSA North", "GSA South",
                                                                             "Dehcho North", "Dehcho South",
                                                                             "Hay River Lowlands"))]
                                            }
                                            popModelPlot <- ggplot2::ggplot(data = DT, aes(x = Year,
                                                                                           colour = Herd,
                                                                                           group = climateModel)) +
                                              geom_line(size = 0.9, aes(y = get(paste0("average", yaxis)),
                                                                        group = climateModel,
                                                                        linetype = climateModel)) +
                                              facet_grid(rows = vars(Herd)) +
                                              geom_hline(yintercept = 1, linetype = "dotted",
                                                         color = "grey73", size = 1) +
                                              geom_ribbon(aes(ymin = minRib,
                                                              ymax = maxRib,
                                                              group = climateModel,
                                                              fill = Herd), alpha = 0.1, colour = NA) +
                                              theme_linedraw() +
                                              # ggtitle(label = paste0("Caribou population dynamics: ", climateModel),
                                              #         subtitle = paste0("Female Survival Model: ", survMod,
                                              #                           "\nRecruitment Model: ", recMod)) +
                                              theme(legend.position = "bottom",
                                                    title = element_blank(),
                                                    strip.text.y = element_blank(),
                                                    legend.key = element_blank(),
                                                    legend.title = element_blank(),
                                                    axis.title = element_text(family = "Arial")) +
                                              ylab(expression(Mean~annual~lambda)) +
                                              xlab("year") +
                                              guides(color = guide_legend(nrow = rowsLegend,
                                                                          byrow = TRUE))
                                            if ("Replicate" %in% names(DT)){
                                              popModelPlot <- popModelPlot + geom_jitter(data = DT, aes(x = Year,
                                                                                                        y = get(yaxis)),
                                                                                         size = 0.5, colour = "grey40",
                                                                                         width = 0.1)
                                            }

                                            if(currentTime == endTime){
                                              plotName <- file.path(outputFolder,
                                                                    paste0("caribou_", shp, "_allCM_", province,
                                                                           "_", recMod,"_", survMod,
                                                                           ifelse(!is.null(resultsMainFolder), "_reps", ""),
                                                                           ".png"))
                                              tryCatch(quickPlot::clearPlot(),
                                                       error = function(e){
                                                         message(crayon::red("quickPlot::clearPlot() failed"))
                                                       })
                                              png(plotName,
                                                  units = "cm", res = 300,
                                                  width = 29, height = 21+(1*rowsLegend))
                                              print(popModelPlot)
                                              dev.off()
                                              if (!is.null(uploadPlots))
                                                drive_upload(media = plotName, path = as_id(uploadPlots))
                                            }
                                            return(popModelPlot)
                                          })
                      names(polyReady) <- unique(tableAll[area == shp, femSurvMod_recrMod])
                      return(polyReady)
                    })
  names(yrReady) <- unique(tableAll[["area"]])
  lambdaAverage <- rbindlist(lapply(X = unique(tableAll[["Herd"]]),
                    FUN = function(shp){
                      averageAnnualLambda <- round(mean(tableAll[Herd == shp,
                                                           averageannualLambda]), 3)
                      sdAnnualLambda <- round(sd(tableAll[Herd == shp,
                                                           averageannualLambda]), 3)
                      TB <- data.table(Province = province,
                                       Herd = shp,
                                       averageLambda = averageAnnualLambda,
                                       sdLambda = sdAnnualLambda)
                      return(TB)
                    }))
  return(lambdaAverage)
}
