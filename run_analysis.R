# loading required package

library(dplyr)

# Download the dataset

filename <- "Coursera_DS3_Final.zip"

# Checking if archieve already exists.
if (!file.exists(filename)){
  fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileURL, filename, method="curl")
}  

# Checking if folder exists
if (!file.exists("UCI HAR Dataset")) { 
  unzip(filename) 
}

# Assigning all data frames
# features_info.txt and README.txt don't contain data so were not assigned
# we don't need inertial folder: subsequent steps calls on you to get rid of 
#   all the variables that are not to do with mean or standard deviation 
#  (worked out from the column names- the features) 
#   and you have no names for those columns so they go.

features <- read.table("UCI HAR Dataset/features.txt")
activities <- read.table("UCI HAR Dataset/activity_labels.txt")
subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("UCI HAR Dataset/test/y_test.txt")
subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt")
y_train <- read.table("UCI HAR Dataset/train/y_train.txt")

#change column names to data frames

names(features)<-c("n","functions")
names(activities)<-c("code","activity")
names(subject_test)<-"subject"
names(x_test)<-features$functions
names(y_test)<-"code"
names(subject_train)<-"subject"
names(x_train)<-features$functions
names(y_train)<-"code"

# Step 1: Merges the training and the test sets to create one data set.

X <- rbind(x_train, x_test)
Y <- rbind(y_train, y_test)
Subject <- rbind(subject_train, subject_test)
Merged_Data <- cbind(Subject, Y, X)

#Step 2: Extracts only the measurements on the mean and standard deviation for each measurement.

TidyData <-  select(Merged_Data,subject, code, contains("mean"), contains("std"))

# Step 3: Uses descriptive activity names to name the activities in the data set.

TidyData$code <- activities[TidyData$code, "activity"]

#Step 4: Appropriately labels the data set with descriptive variable names.

  #Name column "code" as "activity"
names(TidyData)[2] = "activity"
# replace abbreviations for more descriptive names

names(TidyData)<-gsub("Acc", "Accelerometer", names(TidyData))
names(TidyData)<-gsub("Gyro", "Gyroscope", names(TidyData))
names(TidyData)<-gsub("BodyBody", "Body", names(TidyData))
names(TidyData)<-gsub("Mag", "Magnitude", names(TidyData))
names(TidyData)<-gsub("^t", "Time", names(TidyData))
names(TidyData)<-gsub("^f", "Frequency", names(TidyData))
names(TidyData)<-gsub("tBody", "TimeBody", names(TidyData))
names(TidyData)<-gsub("-mean()", "Mean", names(TidyData), ignore.case = TRUE)
names(TidyData)<-gsub("-std()", "STD", names(TidyData), ignore.case = TRUE)
names(TidyData)<-gsub("-freq()", "Frequency", names(TidyData), ignore.case = TRUE)
names(TidyData)<-gsub("angle", "Angle", names(TidyData))
names(TidyData)<-gsub("gravity", "Gravity", names(TidyData))

#Step 5: From the data set in step 4, creates a second, independent tidy data set 
#with the average of each variable for each activity and each subject.
FinalData <- TidyData %>%
  group_by(subject, activity) %>%
  summarise_all(mean)
                
write.table(FinalData, "FinalData.txt", row.name=FALSE)
