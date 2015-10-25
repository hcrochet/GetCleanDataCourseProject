#1.
##Download data
filename<-"UCIData.zip"
if (!file.exists(filename)){
        fileUrl <- "http://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
        download.file(fileUrl, filename)
}
if (!file.exists("UCI HAR Dataset")){
        unzip(filename)
}

##Read in the data
subject_test<-read.table("./UCI HAR Dataset/test/subject_test.txt")
X_test<-read.table("./UCI HAR Dataset/test/X_test.txt")
y_test<-read.table("./UCI HAR Dataset/test/y_test.txt")
subject_train<-read.table("./UCI HAR Dataset/train/subject_train.txt")
X_train<-read.table("./UCI HAR Dataset/train/X_train.txt")
y_train<-read.table("./UCI HAR Dataset/train/y_train.txt")
activity_labels<-read.table("./UCI HAR Dataset/activity_labels.txt")
features<-read.table("./UCI HAR Dataset/features.txt")

##Label columns 
colnames(activity_labels)=c('Activity Type', 'Activity Name')
colnames(features) = c('Feature ID', 'Features')
colnames(X_train) = features[,2]
colnames(X_test) = features[,2]

##Combine test and train tables
test_table<-cbind(subject_test, y_test, X_test)
train_table<-cbind(subject_train, y_train, X_train)

##Combine test and train data together

full_table<-rbind(test_table, train_table)

#Add descriptive column names
colnames(full_table)[1] = "Subject ID" 
colnames(full_table)[2] = "Activity Type" 

#2
##Extract only mean or std columns
#Get column names for grep to get proper indices
Columns<-colnames(full_table)

#Use grep to find indices for columns we want to keep (subject and activity)
#as well as the mean and std columns
Mean_Std<-grep("Subject|Activity|mean|std", Columns)
Mean_Std_Table<-full_table[, Mean_Std]

#3 Provide descriptive activity names

Mean_Std_Table$`Activity Type`[Mean_Std_Table$`Activity Type`==1]<-"Walking"
Mean_Std_Table$`Activity Type`[Mean_Std_Table$`Activity Type`==2]<-"Walking Upstairs"
Mean_Std_Table$`Activity Type`[Mean_Std_Table$`Activity Type`==3]<-"Walking Downstairs"
Mean_Std_Table$`Activity Type`[Mean_Std_Table$`Activity Type`==4]<-"Sitting"
Mean_Std_Table$`Activity Type`[Mean_Std_Table$`Activity Type`==5]<-"Standing"
Mean_Std_Table$`Activity Type`[Mean_Std_Table$`Activity Type`==6]<-"Laying"

#4 Add descriptive variable names
names(Mean_Std_Table) <- gsub('\\(|\\)',"",names(Mean_Std_Table), perl = TRUE)
names(Mean_Std_Table)<- gsub("-mean", " Mean", names(Mean_Std_Table))
names(Mean_Std_Table)<-gsub("-std", " StdDev", names(Mean_Std_Table))
names(Mean_Std_Table)<-gsub("BodyAcc", "Body Acceleration", names(Mean_Std_Table))
names(Mean_Std_Table)<-gsub("GravityAcc", "Gravity Acceleration", names(Mean_Std_Table))
names(Mean_Std_Table)<-gsub("BodyGyro", "Body Gyro", names(Mean_Std_Table))
names(Mean_Std_Table)<-gsub("Jerk-", "Jerk ", names(Mean_Std_Table))
names(Mean_Std_Table)<-gsub("Mag", "Magnitude ", names(Mean_Std_Table))
names(Mean_Std_Table)<-gsub("^(t)", "Time", names(Mean_Std_Table))
names(Mean_Std_Table)<-gsub("^(f)", "Frequency", names(Mean_Std_Table))

#5 create a second, independent tidy data set with the average of each variable 
#for each activity and each subject

library(plyr)
#remove spaces from column names, as ddply doesn't like spaces
colnames(Mean_Std_Table)[1] = "SubjectID" 
colnames(Mean_Std_Table)[2] = "ActivityType" 

table2<-ddply(Mean_Std_Table, c('SubjectID', 'ActivityType'), numcolwise(mean))
write.table(table2, file="Summary_Table.txt", row.names=FALSE)
