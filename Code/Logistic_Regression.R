# Logistic Regression
# the low birth weight data set examines the relationship between whether the birth 
# weight of a child is less than 2.5 kg 
# (variable low: 0 is more than or equal to 2.5kg and 1 is less than 2.5 kg) and 
# a number of variables measured on the child's mother. 
# The explanatory variables are: the age of the mother (age), 
# mother's weight in pounds at last menstrual period (lwt), 
# mother's race (race), whether the mother smokes (smoke, 1 for yes), 
# whether the mother worked as premature workers (ptd, 1 for yes), 
# whether the mother has history of hypertension (ht, 1 for yes), 
# presence of uterine irritability (ui, 1 for yes), 
# and number of physician visits during the first trimester 
# (ftv, dummy variable with three levels, 0, 1, and 2+)

#Read in the data
wt <- read.table("https://raw.githubusercontent.com/YuetongLiu/Find_Relationships_in_Data/master/Data/bwt.txt", header=T)
# Or wt <- read.table("./Downloads/bwt.txt", header=T)
wt$race <- as.factor(wt$race)
wt$ftv <- as.factor(wt$ftv)

#Some exploratory plots
#Response against two continuous variables 
#(whether the value of these variables differs at the low=0 group and low=1 group)
par(mfrow=c(1,2))
plot(factor(wt$low),wt$age,main="age")
# Age is relatively higher in the low birth weight group
plot(factor(wt$low),wt$lwt,main="Weight of Mother")
# Weight is lower in the low birth weight group

#Response against other categorical variables
print(table(wt$low,wt$race)) 
#In this table, row is for the first variable and column is for the second variable.
print(table(wt$low,wt$smoke)) 
print(table(wt$low,wt$ptd)) #History of Premature Labor
print(table(wt$low,wt$ht)) #History of Hypertension	
print(table(wt$low,wt$ui)) #Presence of Uterine Irritability 
print(table(wt$low,wt$ftv)) #Number of Physician Visits

# which explanatory variables seem to be associated with low birthweight

fit1 <- glm(low~., data=wt, family="binomial")
summary(fit1)

# see the proportion table here
ht.table <- table(wt$low,wt$ht)	
ht.table[,1] <- ht.table[,1]/sum(ht.table[,1])
ht.table[,2] <- ht.table[,2]/sum(ht.table[,2])
print(ht.table)

sk.table <- table(wt$low,wt$smoke)
sk.table[,1] <- sk.table[,1]/sum(sk.table[,1])
sk.table[,2] <- sk.table[,2]/sum(sk.table[,2])
print(sk.table)

#remove the insignificant variables from the model.
fit2 <- glm(low~lwt+race+smoke+ht+ptd, data=wt, family="binomial")
summary(fit2)

##Prediction with GLM

##Calculate the estimated probabilities.
pred1.prob <- predict(fit1, type="response")
#Choose 0.5 as the cut-off
table(wt$low, as.numeric(pred1.prob>0.5))
#     0   1
# 0 116  14
# 1  37  22
#37+14 of the 189 observations are misclassified with 0.5 for boundary of pred1.prob   

pred2.prob <- predict(fit2, type="response")
table(wt$low, as.numeric(pred2.prob>0.5))
#    0   1
#0 120  10
#1  34  25
#Which model has smaller misclassification rate?


#Predict the probability of giving birth to a low body weight child for a woman who has lwt of 170, age 20, smokes, 
#has premature working history (ptd=1), has hypertension, has uterine irritability and 
# does not visit any physician before giving birth.
xstar <- data.frame(age=20, lwt=170, race="black", smoke=1, ptd=1, ht=1, ui=1, ftv="0")
predict(fit2, newdata=xstar, type="response")


##Two-fold cross-validation.
##Similarly as in the previous lab, we can split the data into two sets and
##test the predictive performance of the logistic models.
set.seed(1)
ind <- sample(1:189, 90)
wt.sub1 <- wt[-ind, ]
wt.sub2 <- wt[ind, ]

fit.sub1 <- glm(low~lwt+race+smoke+ht+ptd, data=wt.sub1, family="binomial")
pred.prob1 <- predict(fit.sub1, newdata=wt.sub2, type="response")
pt1 <- table(wt.sub2$low, as.numeric(pred.prob1>0.5))
pt1

#Reverse the training and hold-out set.
fit.sub2 <- glm(low~lwt+race+smoke+ht+ptd, data=wt.sub2, family="binomial")
pred.prob2 <- predict(fit.sub2, newdata=wt.sub1, type="response")
pt2 <- table(wt.sub1$low, as.numeric(pred.prob2>0.5))
pt2

##Total misclassification rate
(pt1[1,2] + pt1[2, 1] + pt2[1,2] + pt2[2, 1])/189
#0.3227513
#Modify the above code to calculate the misclassification rate of the full model. 

