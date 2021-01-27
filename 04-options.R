################################################################################
## Options
################################################################################

cacheDBconn <- if (config::get("cachedb") == "sqlite") {
  NULL ## default to sqlite
} else if (config::get("cachedb") == "postgresql") {
  DBI::dbConnect(drv = RPostgres::Postgres(),
                 host = Sys.getenv("PGHOST"),
                 port = Sys.getenv("PGPORT"),
                 dbname = Sys.getenv("PGDATABASE"),
                 user = Sys.getenv("PGUSER"),
                 password = Sys.getenv("PGPASSWORD"))
} else {
  stop("Unsupported cache database type '", config::get("cachedb"), "'")
}

maxMemory <- 5e+12

rasterOptions(default = TRUE)
opts <- options(
  "LandR.assertions" = FALSE,
  "LandR.verbose" = 1,
  "rasterMaxMemory" = maxMemory,
  "rasterTmpDir" = scratchDir,
  "reproducible.cachePath" = file.path(scratchDir, "cache"),
  "reproducible.cacheSaveFormat" = cacheFormat,
  "reproducible.conn" = cacheDBconn,
  "reproducible.destinationPath" = normPath(defaultPaths[["inputPath"]]),
  "reproducible.inputPaths" = NULL,
  "reproducible.nThreads" = 2,
  "reproducible.overwrite" = TRUE,
  "reproducible.polygonShortcut" = FALSE,
  "reproducible.quick" = FALSE,
  "reproducible.showSimilar" = TRUE,
  "reproducible.useCache" = TRUE,
  "reproducible.useCloud" = TRUE,
  "reproducible.useGDAL" = FALSE, ## TODO: can't use true until system call bugs are resolved
  "reproducible.useMemoise" = FALSE,
  "reproducible.useNewDigestAlgorithm" = TRUE,
  "reproducible.useRequire" = useRequire,
  "spades.moduleCodeChecks" = codeChecks,
  "spades.nThreads" = 4,
  "spades.recoveryMode" = FALSE,
  "spades.restartR.restartDir" = defaultPaths[["outputPath"]],
  "spades.useRequire" = useRequire
)

library(googledrive)

httr::set_config(httr::config(http_version = 0))
httr::timeout(seconds = 10)

drive_auth(email = config::get("cloud")[["googleuser"]], use_oob = quickPlot::isRstudioServer())
message(crayon::silver("Authenticating as: "), crayon::green(drive_user()$emailAddress))
