library(tidyverse)

predictions<-read.table("/Users/stevensmith/Projects/OpenBioLink_sandbox/prediction_results/TransE_l1_OBL_21_results.compiled_results.csv",sep="\t",header=F)
in_train<-read.table("/Users/stevensmith/Projects/OpenBioLink_sandbox/in_train",sep="\t",header=F)
in_test<-read.table("/Users/stevensmith/Projects/OpenBioLink_sandbox/in_test_val",sep="\t",header=F)


nrow(predictions)
head(in_train)
in_train.keys<-unite(in_train,"key")
in_test.keys<-unite(in_test,"key")
predictions.keys<-data.frame(unite(select(predictions,c(V1,V2,V3)),"key"),score=predictions$V4)
head(predictions.keys)

intersect(predictions.keys$key,in_train.keys$key)

predictions.keys.remtrain<-filter(predictions.keys,!key %in% in_train.keys$key)

in_train.keys$set<-"in_train"
in_test.keys$set<-"in_test"

merge(predictions.keys.remtrain,in_test.keys,all.x = T)


intersect(predictions.keys.remtrain$key,in_test.keys$key)


head(predictions.keys.remtrain,30)
