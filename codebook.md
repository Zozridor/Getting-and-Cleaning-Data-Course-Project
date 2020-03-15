---
title: "codebook.md"
output: html_document
---


I started off by setting up my working directories and getting the data from the files

```{r}
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

```

The next step was to merge my training and testing sets. I called the resulting dataset "completeData" because it included all the data, not only the std and mean, which I extract during the following step.


```{r cars}
mergedY <- rbind(ytrain, ytest)
mergedX <- rbind(xtrain, xtest)
mergedSubject <- rbind(trainSubjects, testSubjects)

completeData <- cbind(mergedSubject, mergedX, mergedY)
```

I have my complete dataset but now I need to extract the mean and std. I use grepl and regex to identify the columns I need. After I have that data, I put it into a set called "unorderedData" because the activityID is at the end. The next few lines of code correct the column order and put it into a much more readable dataset called "extractedData." Finally, I add in the activity descriptions.

```{r}
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
```
For the final step, I use dplyr to get the mean for each variable by subjectID and activityID. I then write in into a table.

```{r}
tidyData <- extractedData %>%
  dplyr::group_by(subjectID, activityID) %>%
  dplyr::summarise_all(dplyr::funs(mean))

write.table(tidyData, "final.txt")
```
