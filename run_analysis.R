library(dplyr)

#Reading in all the data and naming columns
setwd("~/Documents/Data_Science_Files/RStudio Projects/Coursera/Getting-and-Cleaning-Data-Course-Project/UCI HAR Dataset")
features <- read.table("features.txt")
actLabels <- read.table("activity_labels.txt")

setwd("./train")
trainSubjects <- read.table("subject_train.txt")
colnames(trainSubjects) <- "subjectID"
xtrain <- read.table("X_train.txt")
colnames(xtrain) <- features[,2]
ytrain <- read.table("y_train.txt")
colnames(ytrain) <- "activityID"

setwd("../test")
testSubjects <- read.table("subject_test.txt") 
colnames(testSubjects) <- "subjectID"
xtest <- read.table("X_test.txt")
colnames(xtest) <- features[,2]
ytest <- read.table("y_test.txt")
colnames(ytest) <- "activityID"

#Merging the data
mergedY <- rbind(ytrain, ytest)
mergedX <- rbind(xtrain, xtest)
mergedSubject <- rbind(trainSubjects, testSubjects)

completeData <- cbind(mergedSubject, mergedX, mergedY)

#Extracting mean and std data only
IdExtractor <- grepl("subjectID", colnames(completeData))
actExtractor <- grepl("activityID", colnames(completeData))
meanExtractor <- grepl(".*mean.*", colnames(completeData))
stdExtractor <- grepl(".*std.*", colnames(completeData))

unorderedData <- completeData[, IdExtractor | actExtractor | meanExtractor | stdExtractor]

#Moving the activityID from the last column to the second
extractedData <- unorderedData[ ,c(1,81,2:80)]

#Adding in activity descriptions
extractedData$activityType <- actLabels$V2[extractedData$activityID]
extractedData <- extractedData[,c(1,2,82,3:81)]

#Final data set with summary
tidyData <- extractedData %>%
  dplyr::group_by(subjectID, activityID) %>%
  dplyr::summarise_all(dplyr::funs(mean))

write.table(tidyData, "final.txt", row.name = F)