library(readr)
library(RSQLite)

col_names <- c(
  "GLOBALEVENTID",
  "SQLDATE",
  "MonthYear",
  "Year",
  "FractionDate",
  "Actor1Code",
  "Actor1Name",
  "Actor1CountryCode",
  "Actor1KnownGroupCode",
  "Actor1EthnicCode",
  "Actor1Religion1Code",
  "Actor1Religion2Code",
  "Actor1Type1Code",
  "Actor1Type2Code",
  "Actor1Type3Code",
  "Actor2Code",
  "Actor2Name",
  "Actor2CountryCode",
  "Actor2KnownGroupCode",
  "Actor2EthnicCode",
  "Actor2Religion1Code",
  "Actor2Religion2Code",
  "Actor2Type1Code",
  "Actor2Type2Code",
  "Actor2Type3Code",
  "IsRootEvent",
  "EventCode",
  "EventBaseCode",
  "EventRootCode",
  "QuadClass",
  "GoldsteinScale",
  "NumMentions",
  "NumSources",
  "NumArticles",
  "AvgTone",
  "Actor1Geo_Type",
  "Actor1Geo_FullName",
  "Actor1Geo_CountryCode",
  "Actor1Geo_ADM1Code",
  "Actor1Geo_ADM2Code",
  "Actor1Geo_Lat",
  "Actor1Geo_Long",
  "Actor1Geo_FeatureID",
  "Actor2Geo_Type",
  "Actor2Geo_FullName",
  "Actor2Geo_CountryCode",
  "Actor2Geo_ADM1Code",
  "Actor2Geo_ADM2Code",
  "Actor2Geo_Lat",
  "Actor2Geo_Long",
  "Actor2Geo_FeatureID",
  "ActionGeo_Type",
  "ActionGeo_FullName",
  "ActionGeo_CountryCode",
  "ActionGeo_ADM1Code",
  "ActionGeo_ADM2Code",
  "ActionGeo_Lat",
  "ActionGeo_Long",
  "ActionGeo_FeatureID",
  "DATEADDED",
  "SOURCEURL"
)

col_types <- cols(
  col_integer(),
  col_character(),
  col_integer(),
  col_integer(),
  col_double(),
  col_character(),
  col_character(),
  col_character(),
  col_character(),
  col_character(),
  col_character(),
  col_character(),
  col_character(),
  col_character(),
  col_character(),
  col_character(),
  col_character(),
  col_character(),
  col_character(),
  col_character(),
  col_character(),
  col_character(),
  col_character(),
  col_character(),
  col_character(),
  col_integer(),
  col_character(),
  col_character(),
  col_character(),
  col_integer(),
  col_double(),
  col_integer(),
  col_integer(),
  col_integer(),
  col_double(),
  col_integer(),
  col_character(),
  col_character(),
  col_character(),
  col_character(),
  col_double(),
  col_double(),
  col_character(),
  col_integer(),
  col_character(),
  col_character(),
  col_character(),
  col_character(),
  col_double(),
  col_double(),
  col_character(),
  col_integer(),
  col_character(),
  col_character(),
  col_character(),
  col_character(),
  col_double(),
  col_double(),
  col_character(),
  col_character(),
  col_character()
)

con <- dbConnect(SQLite(), dbname = "./bfdb2.db")

file_list <- list.files(path='./out', pattern='202401[0-9]{8}.export.CSV', full.names = TRUE)
cat('Number of CSV files found: ', length(file_list), '\n')

success_counter <- 0
fail_counter <- 0

for (file in file_list[-1]) {
  event <- read_delim(
    file,
    delim = "\t",
    escape_double = FALSE,
    col_names = col_names,
    trim_ws = TRUE,
    col_types = col_types
  )

  tryCatch(
    expr = {
      dbWriteTable(con, name = "events", value = event, append = TRUE)
      cat('File', file, 'was written into DB\n')
      success_counter <- success_counter + 1
    },
    error = function(e){
      message('Caught an error!')
      print(e)
      fail_counter <- fail_counter + 1
    },
    warning = function(e){
      message('Caught a warning!')
      print(e)
    }
  )
}

dbDisconnect(con)

cat('SUCCESSES:', success_counter, '\n')
cat('FAILS:', fail_counter, '\n')
