library("data.table")
library("reshape2")

features <- fread("/Users/yang/Downloads/UCI HAR Dataset/features.txt",
                  col.names =  c("index", "featureNames"))
activity_labels <- fread("/Users/yang/Downloads/UCI HAR Dataset/activity_labels.txt",
                         col.names = c("classLabels", "activityName"))

featuresWanted <- grep("(mean|std)\\(\\)", features[, featureNames])
measurements <- features[featuresWanted,featureNames]
measurements <- gsub('[()]','', measurements)


## Loading training set
train <- fread("/Users/yang/Downloads/UCI HAR Dataset/train/X_train.txt")[, featuresWanted, with = FALSE]
data.table::setnames(train, colnames(train), measurements)
train_activities <- fread("/Users/yang/Downloads/UCI HAR Dataset/train/Y_train.txt", col.names = c("Activity"))
train_subjects <- fread("/Users/yang/Downloads/UCI HAR Dataset/train/subject_train.txt", col.names = c("SubjectNum"))
train <- cbind(train_subjects, train_activities, train)

## Loading testing set
test <- fread("/Users/yang/Downloads/UCI HAR Dataset/test/X_test.txt")[, featuresWanted, with = FALSE]
data.table::setnames(test, colnames(test), measurements)
test_activities <- fread("/Users/yang/Downloads/UCI HAR Dataset/test/Y_test.txt", col.names = c("Activity"))
test_subjects <- fread("/Users/yang/Downloads/UCI HAR Dataset/test/subject_test.txt", col.names = c("SubjectNum"))
test <- cbind(test_subjects, test_activities, test)


## Merging Dataset
combined <- rbind(train, test)


## Converting classLabels to activityName basically. More explicit. 

combined[["Activity"]] <- factor(combined[, Activity], 
                                 levels = activity_labels[["classLabels"]],
                                 labels = activity_labels[["activityName"]])

combined[["SubjectNum"]] <- as.factor(combined[,SubjectNum])       
combined <- reshape2::melt(data=combined, id=c("SubjectNum", "Activity"))
combined <- reshape2::dcast(data=combined, SubjectNum + Activity ~ variable, fun.aggregate = mean)

data.table::fwrite(x = combined, file = "/Users/yang/Downloads/UCI HAR Dataset/tidyData.txt", quote = FALSE)
