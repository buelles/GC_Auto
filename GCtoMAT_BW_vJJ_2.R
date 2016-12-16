### - GCtoMAT_BW_vJJ - ###
# Adapted from GCtoMAT_BW_v2.R
# Brian Whyte
# ba.whyte@berkeley.edu

# ----- READ ME ----- # <---- <---- <---- <---- <---- <----
### OBJECTIVE ###
# 1)  Gather .csv files from directory 
# 2)  Extract only RT and Area data from .csv files into a shared list
# 3)  Organize (via merge function) into one matrix based on masterRT values
# 4)  Export as single .csv with all relevant GC/MS data for analysis

### INSTRUCTIONS ###
# 1) Have all .csv files in working directory
# 3) Source this script (i.e. run it all at once) and look for "matrix.csv" in your directory.
#    This matrix is the combined data of all RESULTS.CSV files, making for easier comparitive analysis.
# - Always let me know if you run into problems:
#           ba.whyte@berkeley.edu
# - glhf
#
# PATCH NOTES
# vJJ_2   - Output is now a Area vs. RT matrix
#         - Merging to masterRT no longer rounds or subsequently removes duplicates
#
# ----- EXTRACT AND MERGE DATA ----- 
## Retrieve all csv's in the directory
setwd("C:/Users/Brian/Desktop/R_folder/GCtoMAT/vJJ") # <--- set your own wd!
## Housekeeping
cat("\014") # Clear console
rm(list=ls()) # Remove all variables
require(stringi) # package for stri_list2matrix()

## Make list of file names
names <- list.files(pattern="*.csv")
l <- list() # empty list to be filled below
## Gather .csv data into list, where each object is RT or Area data from .csv's
for (i in 1:length(names)) {
  df <- assign(names[i], read.csv(names[i],skip=3)) # skip=3 means first 3 rows skipped
  df <- df[-c(1,3,4,6,7)] # remove all but RT and Area columns
  colnames(df) <- c("RT","Area")
  n <- names[i]
  l[[paste(c(n,"_RT"),sep="",collapse="")]] <- df$RT
  l[[paste(c(n,"_Area"),sep="",collapse="")]] <- df$Area
}
## Create masterRT df for merging other RT + Area data onto it
masterRT <- unique(sort(as.vector(unlist(l[which(grepl("RT",names(l)))]))),decreasing=FALSE)
dfRT <- data.frame(masterRT,stringsAsFactors = FALSE)
tempdf <- stri_list2matrix(l)
colnames(tempdf) <- names(l)
tempdf[is.na(tempdf)] <- 0
tempdf <- as.data.frame(tempdf)
## Merge all RT + Area data, such that they are organized based on the masterRT
for (j in 1:length(names)) {
  ndf <- tempdf[which(grepl(names[j],names(tempdf)))]
  ndf["masterRT"] <- ndf[1]
  dfRT <- merge(dfRT,ndf,by = "masterRT", all.x=TRUE)
}
dfArea <- dfRT[,-which(grepl("_RT",names(dfRT)))] # remove RT data, leaving only area data
m <- as.matrix(dfArea) # convert data frame to matrix so eliminating NA's is easy
m[is.na(m)] <- 0
m <- t(m) # transpose the matrix, switchin the x and y axis
## Export this matrix into an excel file
final_m <- as.data.frame(m, stringsAsFactors = FALSE)
write.csv(final_m,file="matrix.csv",row.names=TRUE)
### FINISH ###
