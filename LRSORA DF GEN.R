library("tidyverse")
library("lubridate")
library("xlsx")
library("scales")

dataIn <- readLines(file.choose())

usefulLines <- dataIn[str_detect(dataIn, "\\*|\\w{2}\\s\\d{4}\\s\\d+|[R][e][f][.]")]
numResults <- sum(str_detect(usefulLines,"\\w{2}\\s\\d{4}\\s\\d+"))
framedData <- data.frame(Name = character(numResults), Chart = integer(numResults), SpecimenType = character(numResults), Test = character(numResults),
                         Accession = character(numResults), Result = character(numResults),
                            Time = character(numResults), Location = character(numResults), stringsAsFactors = FALSE)
#Only pulls lines of report with data to be put into a frame
#Format is:
#1 NAME,NAME NAME    CHART#              **NO ENTRY**
#2 SpecType    Ref. Range: X - Y UNITS
#3 TEST    ACCESSION     RESULTS   TIMEPERFORMED   LOCATION
#1 INDICATES NEW PATIENT FOR TIME RANGE
#2 INDICATES A NEW SPECIMEN TYPE WITH NEW RANGES
#3 INDICATES TEST RESULTS
#SIMPLE CASE IS 1,2,3 BUT MAY HAVE 123+, 1(23)+,1(23)+3+ ETC...
#reference ranges are not pulled as my experience is that this does not populate correctly in the report
#fill data frame with data extracted from usefulLines
currPT <- c("","")
currTYPE <- ""
currROW <- 1
for(line in seq_along(usefulLines)){
  if(str_detect(usefulLines[line], "\\*")){
    currPT <- c(str_trim(str_match(usefulLines[line], "^(.+\\D)\\s?\\d")[,2]), str_extract(usefulLines[line], "\\d+"))
    
    #str_match returns a vector with the whole thing and the captured group, str_extract returns the matched group
  }
  if(str_detect(usefulLines[line], coll("Ref."))){
    currTYPE <- str_match(usefulLines[line], "^\\s{2}(\\w+)\\s")[,2]
    
  }
  if(str_detect(usefulLines[line], "\\w{2}\\s\\d{4}\\s\\d+")){
  #if result, put info in currROW with currPT and currTYPE, increment currROW by 1
    testName <- str_trim(str_match(usefulLines[line],  "^(.+)\\s?\\w{2}\\s\\d{4}\\s\\d+")[,2])
    accession <- str_extract(usefulLines[line], "\\w{2}\\s\\d{4}\\s\\d+")
    result <- str_trim(str_match(usefulLines[line], "\\w{2}\\s\\d{4}\\s\\d+\\s?(.+)\\s?\\w{3}\\s\\d{2}\\s\\d{4}")[,2])
    datetime <- str_extract(usefulLines[line], "\\w{3}\\s\\d{2}\\s\\d{4}\\s[a][t]\\s.{5}")
    location <- str_match(usefulLines[line], "\\d{2}[:]\\d{2}\\s*(.+)$")[,2]
    framedData[[currROW, "Name"]] <- currPT[1]
    framedData[[currROW, "Chart"]] <- currPT[2]                        
    framedData[[currROW, "SpecimenType"]] <- currTYPE
    framedData[[currROW, "Test"]] <- testName
    framedData[[currROW, "Accession"]] <- accession
    framedData[[currROW, "Result"]] <- result
    framedData[[currROW, "Time"]] <- datetime
    framedData[[currROW, "Location"]] <- location
    currROW <- currROW + 1
    
  }
  
}
#TYPE CONVERSIONS
framedData$SpecimenType <- factor(framedData$SpecimenType)
framedData$Test <- factor(framedData$Test)
framedData$Time <- format(as.Date(framedData$Time, "%b %d %Y at %H:%S"), "%b %d %Y")
#typically data by day is more useful for clinics/hospitals than data by hour or minute
message(c("It is ", currROW - 1 == numResults), " that the data frame was successfully populated")
