# LRSORA-DF-Generator
Dataframe generator for use with Indian Health Service's (IHS) Laboratory Package LRSORA Routine (Search for test by high/low value)

The LRSORA Routine of the RPMS LR Package provides a fast method for pulling laboratory testing data with a variety of conditions and over long period of time. It provides a report in seconds in a preconfigured format, compared to a Fileman search in the V LAB file where the user can specify the format of the data printed but may take over an hour to build and print the report. While Fileman data pulls are more convenient for data analysis, the time difference for reports from Fileman verses coded reports in the laboratory package is incredibly significant.

This is intended to be a starter for data analysis using a LRSORA generated report. By pulling the components of the report into a dataframe, further analysis is simple using R packages such as dplyr and ggplot2.
