library(dplyr)
library(data.table)

# note: edit folder path as requried
setwd("C:/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/")

# read Activity Labels and Feature data files
ActivityLabels<-fread("activity_labels.txt")
Features<-fread("features.txt")

# read Test data files
Xtest<-fread("../UCI HAR Dataset/test/X_Test.txt")
Ytest<-fread("../UCI HAR Dataset/test/y_Test.txt")
SubjectTest<-fread("../UCI HAR Dataset/test/subject_Test.txt")

# read Train data files
Xtrain<-fread("../UCI HAR Dataset/train/X_Train.txt")
Ytrain<-fread("../UCI HAR Dataset/train/y_Train.txt")
SubjectTrain<-fread("../UCI HAR Dataset/train/subject_Train.txt")

Xmerged  = bind_rows(Xtrain,Xtest)  # Merger Train and Test data
Ymerged  = bind_rows(Ytrain,Ytest)  # merge Train and Test for Activity data
SubjectMerged  = bind_rows(SubjectTrain,SubjectTest) # merge Train and Test for Subject data

# remove illegal characters  (),  before replacing column names merged data set
Features$V2<-gsub("\\(|\\)","",Features$V2)  # replace ( or ) with nothing
Features$V2<-gsub("\\,","to",Features$V2) # replace , with to
Features$V2<-gsub("-","\\.",Features$V2) # replace - with .

# rename duplicate names
Features$V2<-make.names(Features$V2,unique=TRUE)

# replace column names in merged data set
data.table::setnames(Xmerged,old=names(Xmerged),new=Features$V2)


# Add (join) activity descritions to Activity data frame
Ymerged<-left_join(Ymerged,ActivityLabels,by="V1")

# extract names of columns for average (mean) or Standard deviation (std)
ExtractedNames<-names(Xmerged)[grepl("(mean|std)",tolower(names(Xmerged)))]

# remove only mean and std columns 
Xmerged<- select(Xmerged,all_of(ExtractNames))

# Join Subject and Activity description to mean and std data
Xmerged<-bind_cols("Activity"= Ymerged$V2,"TestSubject"= SubjectMerged$V1,Xmerged)


#group data by Activity and subject 
Xgrouped <- group_by(Xmerged,Activity,TestSubject)

#calculate the mean of each grouping
Xgrouped <-summarise_at(Xgrouped,.vars=ExtractedNames,mean,rm.na=TRUE)

write.table(Xgrouped,file="../Xgrouped.txt",row.name=FALSE)
