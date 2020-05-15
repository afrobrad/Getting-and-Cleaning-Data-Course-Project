Getting and Cleaning Data Course Project Code Book
================
Brad Martin
15 May 2020

## Outline

This document outlines the work completed for the “Getting and Cleaning
Data Course” project which is part of the John Hokpins Data Science
Specialization on Coursera taught by J.Leek, R.Peng and B.Caffo.

The objective of the project was to “..demonstrate your ability to
collect, work with, and clean a data set”.

Project Data Deliverables:

  - A tidy version of the of original data set including:
      - Merged training and test  
      - Only mean and standard deviation fields for each measurement  
      - Descriptive activity names to name the activities in the data
        set  
      - Data labelled with descriptive variable names  
  - A second, independent tidy data set including:
      - the average of each variable for each activity and each subject

A data set was chosen from a previous study conducted on “Human Activity
Recognition Using Smartphones Data Set” by Davide Anguita et al at

Reference: Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and
Jorge L. Reyes-Ortiz. A Public Domain Dataset for Human Activity
Recognition Using Smartphones. 21th European Symposium on Artificial
Neural Networks, Computational Intelligence and Machine Learning, ESANN
2013. Bruges, Belgium 24-26 April 2013

In summary, acceleration and velocity measurements were made with the
accelerometer and gyroscope from a Samasung Galaxy Smart phone while 30
participant participated in various activites such as standing and
walking and the transition between the activities. Further details can
be found in the Readme.txt file in the original dataset and the UCI
webiste linked below. Details on each measurement / variable can be
found in featues\_info.txt. Further explaination is not required for the
execution of the project requirements.

# Data Source

Data used for this project was taken from:  
<https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip>

Original data is available from UCI’s Maching Learning Repository:  
<http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones>

# Data Structure:

The following data was used :

| File Name            | Descritpion                                                          | Obserations / Issues                                             |
| -------------------- | -------------------------------------------------------------------- | ---------------------------------------------------------------- |
| features.txt         | Reference (column) names for data collected in the study             | Contains characters such as **( ) , -** illegal for column names |
| activity\_labels.txt | Reference table with activity names                                  | Contains 2 columns, Index and names                              |
| train/X\_train.txt   | Calculated data (eg mean, min, max) for each particiant and activity | Contains 561 columns of data, no index or reference column       |
| train/y\_train.txt   | Activty observered during for each measurement                       | Contains 1 column of data, no index or reference column          |
| test/X\_test.txt     | Summary of data measured for each particiant and activity            | Contains 561 columns of data, no index or reference column       |
| test/y\_test.txt     | Activty observered during for each measurement                       | Contains 1 column of data, no index or reference column          |

Reference files:

| File Name          | Descritpion                                        |
| ------------------ | -------------------------------------------------- |
| README.txt         | Information on the project                         |
| features\_info.txt | Information about each variable/column in data set |

Based on the reference information, each obsveration (vector) is in a
separate row and each measurement/calcuation . No transformation is
therefore necessary.

Although not explicitly stated and with lack of index / key in the main
data file x\_test.txt and x\_train.txt, it was assumed the rows
corresponded in each file to the same observation.

Additional Raw measurement data contained in the original data package
was not required for the project deliverables.

#### Example of first 10 columns of x-test.txt and y-test.txt

[Link](<https://github.com/afrobrad/Getting-and-Cleaning-Data-Course-Project/blob/master/Xtrain.PNG>)

#### Example of y\_train.txt and y-test.txt

[Link](<https://github.com/afrobrad/Getting-and-Cleaning-Data-Course-Project/blob/master/Ytrain.PNG>)

#### Example of features.txt

[Link](<https://github.com/afrobrad/Getting-and-Cleaning-Data-Course-Project/blob/master/Features.PNG>)

#### Example of activity\_labels.txt

[Link](<https://github.com/afrobrad/Getting-and-Cleaning-Data-Course-Project/blob/master/ActivityLabel.PNG>)

# Tidy Script

### Load packages

``` {r}
library(dplyr)
library(data.table)
```

### Read Source files into R

Analysis was conducted on underpowered Window 10 PC so to speed up
ingestion, **fread** was used instead **read.table**.

#### Set local folder

Adjust folder path based on location of source data

``` {r}
setwd("C:/getdata_projectfiles_UCI HAR Dataset/UCI HAR Dataset/")
```

#### Read Activity Labels and Feature data files

``` {r}
ActivityLabels<-fread("activity_labels.txt")
Features<-fread("features.txt")
```

#### Read Test data files

``` {r}
Xtest<-fread("../UCI HAR Dataset/test/X_Test.txt")
Ytest<-fread("../UCI HAR Dataset/test/y_Test.txt")
SubjectTest<-fread("../UCI HAR Dataset/test/subject_Test.txt")
```

#### Read Train data files

``` {r}
Xtrain<-fread("../UCI HAR Dataset/train/X_Train.txt")
Ytrain<-fread("../UCI HAR Dataset/train/y_Train.txt")
SubjectTrain<-fread("../UCI HAR Dataset/train/subject_Train.txt")
```

### Merge Training and Test Data Sets

Each file contains the same number of columns and it was assmued to be
same in the . Error checking ommitted to simplify script. Dplyr
bind\_row

``` {r}
Xmerged  = bind_rows(Xtrain,Xtest)  # Merger Train and Test data
Ymerged  = bind_rows(Ytrain,Ytest)  # merge Train and Test for Activity data
SubjectMerged  = bind_rows(SubjectTrain,SubjectTest) # merge Train and Test for Subject data
```

### Rename columns

#### Remove illegal charactors

The names for each measurement in Features.txt contain the illegal
characters **( ) , - .**. These must be removed before replacing column
names in the merged data set. In order to modify the names in tidy
manner, it was decided to cleanup remove/replace the specific
characters. The **make.names** function is too blunt a tool, replacing
all illegal characters with **.** and the resultant names were not
considered tidy.

``` {r}
Features$V2<-gsub("\\(|\\)","",Features$V2)  # replace ( or ) with nothing
Features$V2<-gsub("\\,","to",Features$V2) # replace , with to
Features$V2<-gsub("-","\\.",Features$V2) # replace - with .
```

#### Rename duplicate names

Several measurements(columns) in the dataset are repeated and have the
same name. To avoid conflict, the duplicate names are renamed.
**make.names** locates duplicates and with the flag **unique= TRUE**, it
adds an index to the duplicated names for easy identification.

``` {r}
Features$V2<-make.names(Features$V2,unique=TRUE)
```

#### Replace column names in merged data set

The setnames function from the **data.table** package is simple way to
replace data frame names with new names contained in a vector.

``` {r}
data.table::setnames(Xmerged,old=names(Xmerged),new=Features$V2)
```

### Join activity descriptions to Activity data frames

Join Activity lablels to the activy number which is the common
referencein both data frames.

``` {r}
Ymerged<-left_join(Ymerged,ActivityLabels,by="V1")
```

### Prepare Tidy data set

#### Extract names of columns for average (mean) or Standard Deviation (std)

The columns containing mean and standard devation data are labelled with
mean, Mean and std. grep1 is used to return the columns names that
contin the key words and a new vector is created to hold them. All names
are coverted to lower case to ensure all cases are found.

``` {r}
ExtractedNames<-names(Xmerged)[grepl("(mean|std)",tolower(names(Xmerged)))]
```

#### Separate data

Remove only mean and std columns found in the previous step.

``` {r}
Xmerged<- select(Xmerged,all_of(ExtractNames))
```

#### Join Subject and Activity description to mean and standard deviation data

``` {r}
Xmerged<-bind_cols("Activity"= Ymerged$V2,"TestSubject"= SubjectMerged$V1,Xmerged)
```

### Prepare Second Tidy data set

#### Group data by Activity and subject

The measured data is first grouped by Activity then by test subject.

``` {r}
Xgrouped <- group_by(Xmerged,Activity,TestSubject)
```

#### Calculate the mean of each grouping

Summarise function is used to calculate the mean. N/A data is removed
with the **rm.na=TRUE** flag.

``` {r}
Xgrouped <-summarise_at(Xgrouped,.vars=ExtractedNames,mean,rm.na=TRUE)
```

# Project Output

The tidy script results in the following outputs:

### Xmerged

[Link](<https://github.com/afrobrad/Getting-and-Cleaning-Data-Course-Project/blob/master/Xmerged.PNG>)

### Xgrouped

[Link](<https://github.com/afrobrad/Getting-and-Cleaning-Data-Course-Project/blob/master/Xgrouped.PNG>)
