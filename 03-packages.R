## ensure plyr loaded before dplyr or there will be problems
Require(c("plyr", "PredictiveEcology/SpaDES.core@development"),
        which = c("Suggests", "Imports", "Depends"), upgrade = FALSE) # need Suggests in SpaDES.core
Require("slackr")
