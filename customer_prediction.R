#-----------------------------------------------------------------------------
#Data Analysis and Desicion-making
#Title- Predicting potential customers for a Health Insurance Company
#-----------------------------------------------------------------------------
  
#Introduction 
#-------------------------------------------------------------------------------------------  
#1.1 Problem Description
#Our analysis is focussed on the problem which insurance providers are facing today
#to define their target market nd plan their sale strategies which helps them increase
#their market share and thereby, maximize their profitability.
#--------------------------------------------------------------------------------------------
  

#1 Load Libraries

  
library(e1071) #Package for Skewness function used for data analysis
library(stats) #Package for finding cook's distance
library(ggplot2)#Package for visualisation of data
library(Amelia)#package to visually display the missing values
library(gridExtra)#Package for arranging different plots in a single grid
library(caTools)# Package for validation of models
library(ROCR)#Package for ROC graphs
library(AER)

#----------------------
#2 Data Pre-Processing 
#----------------------
  
#Description
  
#Cross-section data originating from the Medical Expenditure Panel Survey 
#survey conducted in 1996.

data(HealthInsurance)

#Format
#A data frame containing 8,802 observations on 11 variables. 

#--------------------
#2.1 Load the data
#--------------------

library("AER")
data("HealthInsurance")
View(HealthInsurance)
summary(HealthInsurance)

#Initially we will process the data by discovering and labeling the missing data with NA; 
#and converting categorical variable(s) to proper factors with meaningful labels.

#------------------------------------
#2.2 FIle Structue and Content
#------------------------------------ 
  
head(HealthInsurance)
str(HealthInsurance)

#-------------------
#2.3 Missing Values
#-------------------
  
#Replace the possible missing values with NA

summary(HealthInsurance)
HealthInsurance$age[HealthInsurance$age==0]<- NA
HealthInsurance$family[HealthInsurance$family==0]<- NA

#Function missmap is used to check if the data is complete. 

missmap(HealthInsurance, main ="Missing values vs observed")

#-------------------------------------------------
#2.4 Validating Total factor variable in dataset.
#-------------------------------------------------
is.factor(HealthInsurance$ethnicity)

is.factor(HealthInsurance$health)

is.factor(HealthInsurance$limit)

is.factor(HealthInsurance$gender)

is.factor(HealthInsurance$age)

is.factor(HealthInsurance$insurance)

is.factor(HealthInsurance$selfemp)

is.factor(HealthInsurance$family)

is.factor(HealthInsurance$region)

is.factor(HealthInsurance$married)

is.factor(HealthInsurance$education)

#We can see that all the variables are factor except age and family variables. 
#For Better understanding, of how R is going to deal with the categorical variables,
#We can use the contrasts() function for the factors.


contrasts(HealthInsurance$health)
contrasts(HealthInsurance$limit)
contrasts(HealthInsurance$gender)
contrasts(HealthInsurance$insurance)
contrasts(HealthInsurance$married)
contrasts(HealthInsurance$selfemp)
contrasts(HealthInsurance$region)
contrasts(HealthInsurance$ethnicity)
contrasts(HealthInsurance$education)

#It can be said that the raw data taken is a processed data and 
#does not need any cleaning or formatting.

#-------------------------------------
#3 Exploratory Data Visualisation
#-------------------------------------

#-------------------------------------------
#3.1 Scatter plots for Continous Variable
#-------------------------------------------
  

#pairs(~health,age,limit,gender,insurance,married,selfemp,family,region,tehnicity,education ,data=HealthInsurance)
#Unlike pairs(), ggpairs() works with non-numeric and predictors in addition to numeric ones.
#Hence we use simple plot for the output. 

plot1 = qplot(age, data = HealthInsurance, xlab = "age")
plot2 = qplot(age, data = HealthInsurance, geom = "density", fill = "red")
plot3 = qplot(sample = age, data = HealthInsurance) 
grid.arrange(plot1, plot2, plot3, ncol = 3)

plot4 = qplot(family, data = HealthInsurance, xlab = "Evaluation")
plot5 = qplot(family, data = HealthInsurance, geom = "density", fill = "red")
plot6 = qplot(sample = family, data = HealthInsurance) 
grid.arrange(plot4, plot5, plot6, ncol = 3)

#Analysis 
#On observing the density plot graph , we can conclude that variable age is normally distributed and 
#not skewed as the normal distribution graph is neither left nor right skewed. 
#Since the variable is not skewed so we need not use any tranformations like log or sqrt 
#to make age variable normally distributed.
#We can observe that the age is uniformly clustered around qauantile[-4:4]

#-----------------
#3.2 Skewness
#-----------------

#We can also check the skewness using skewness() function: 

skewness(HealthInsurance$age)
skewness(HealthInsurance$family)
#It can be seen that skewness factor is close to zero for age so 
#we can say that age is not skewed. However, family variable exhibit right skewness as the values is positive 
#hence we can use log or sqrt tranformation for the same.

log.y<-log(HealthInsurance$family)
plot7 <-plot(log.y,xlab="family",ylab="Log(family)")

sqrt.y<-sqrt(HealthInsurance$family)
plot8 <-plot(sqrt.y,xlab="famlily",ylab="Sqrt(family)")

#-------------------------------
#3.3 BoxPlots and Stripcharts
#-------------------------------
  
#Scatterplot matrix of all the continous variables while 
#viewing the insurance variable as the output variable.

plot4<- qplot(insurance,family, data=HealthInsurance, geom=c("boxplot"))

plot5<- qplot(insurance,age, data=HealthInsurance, geom=c("boxplot"))

grid.arrange(plot4, plot5)

#Visual Inspection between the 2 continous variables: Family vs age box plots tells us 
#that there is considerable amount of potential outliers for family variable

#-----------------------
#3.4 Z-Scores Scaling
#-----------------------

numeric_data <- HealthInsurance[,c("family","age")]
numeric_data <- data.frame(scale(numeric_data ))
healthinsurance_r = data.frame(scale(numeric_data))
summary(numeric_data)

#Mean after rescaling the variables is 0 for both the variables.
#Checking the 1st and 3rd quantiles for both the variables we can infer
#that they lie between -2 and +2 with few exceptions.


#We will now plot boxplot and strip charts on the basis of z-score

boxplot(numeric_data, main = "Boxplot of re-scaled variables",col = (c("gold","darkgreen")))
stripchart(numeric_data, vertical = TRUE, method = "jitter", col = (c("gold","darkgreen")), pch = 1, main = "Stripcharts of re-scaled variables")

#It provides confirmation of the variable transformations as all the variables now have mean 0. 
#Also , the number of potential outliers are distinctly visible for family after z-score tranformations. 

#--------------------------
#3.5 Correlation Matrix
#--------------------------

cor(numeric_data)

#Family and age have inverse relation which should not be the case as family 
#is directly related with age of the person.


#--------------------------------------
#3.6 CHI Square Test of Independence
#--------------------------------------

#The Chi Square test of independence is used to determine if there is a 
#significant relationship between two categorical variables.

a.data <- data.frame(HealthInsurance$insurance, HealthInsurance$health)
a.data = table(HealthInsurance$insurance, HealthInsurance$health) 
print(a.data)
barplot(a.data, beside = TRUE, legend = levels(unique(HealthInsurance$health)))
print(chisq.test(a.data))

a.data <- data.frame(HealthInsurance$insurance, HealthInsurance$limit)
a.data = table(HealthInsurance$insurance, HealthInsurance$limit) 
print(a.data)
barplot(a.data, beside = TRUE, legend = levels(unique(HealthInsurance$limit)))
print(chisq.test(a.data))

a.data <- data.frame(HealthInsurance$insurance, HealthInsurance$gender)
a.data = table(HealthInsurance$insurance, HealthInsurance$gender) 
print(a.data)
barplot(a.data, beside = TRUE, legend = levels(unique(HealthInsurance$gender)))
print(chisq.test(a.data))

a.data <- data.frame(HealthInsurance$insurance, HealthInsurance$married)
a.data = table(HealthInsurance$insurance, HealthInsurance$married) 
print(a.data)
barplot(a.data, beside = TRUE, legend = levels(unique(HealthInsurance$married)))
print(chisq.test(a.data))

a.data <- data.frame(HealthInsurance$insurance, HealthInsurance$selfemp)
a.data = table(HealthInsurance$insurance, HealthInsurance$selfemp) 
print(a.data)
barplot(a.data, beside = TRUE, legend = levels(unique(HealthInsurance$selfemp)))
print(chisq.test(a.data))

a.data <- data.frame(HealthInsurance$insurance, HealthInsurance$region)
a.data = table(HealthInsurance$insurance, HealthInsurance$region) 
print(a.data)
barplot(a.data, beside = TRUE, legend = levels(unique(HealthInsurance$region)))
print(chisq.test(a.data))

a.data <- data.frame(HealthInsurance$insurance, HealthInsurance$ethnicity)
a.data = table(HealthInsurance$insurance, HealthInsurance$ethnicity) 
print(a.data)
barplot(a.data, beside = TRUE, legend = levels(unique(HealthInsurance$ethnicity)))
print(chisq.test(a.data))

a.data <- data.frame(HealthInsurance$insurance, HealthInsurance$education)
a.data = table(HealthInsurance$insurance, HealthInsurance$education) 
print(a.data)
barplot(a.data, beside = TRUE, legend = levels(unique(HealthInsurance$education)))
print(chisq.test(a.data))

#We can infer by Chi Square test that the variable limit is relatively insignificant 
#as compared to other variables. 

#--------------------------
#4 Predictive Modelling
#--------------------------

#4.1 Convert the data into training and Test in 80-20 ratio :
set.seed(100)

split<- sample.split(HealthInsurance,SplitRatio = 0.8)
training<- subset(HealthInsurance, split=="TRUE")
testing<- subset(HealthInsurance, split=="FALSE")

dim(training)
dim(testing)

#-------------------------------
#4.2 Generalized linear Model
#-------------------------------

#We would not be implementing linear or polynomial model as the response is not a continous variable.
#We need the prediction in Yes or No. Hence we would implement glm model with Binomial distribution.
#We cannot implement Poisson Distribution as we have the factors as "Yes" and "No" which would be
#taken as missing values by Poisson. 

#Big Model
model1 <- glm (insurance ~. , data = training, family = binomial(link='logit'))
summary(model1)

#We can see that this model does a good job on deciding the goodness of the training model. 
#If the p-value is less than or equal to the alpha (i.e p < .05), 
#the result is statistically significant. If the p-value is greater than alpha (p > .05), 
#the result is statistically insignificant.

#-------------------------------------------------
#4.3 Hypothesis Testing for Stepwise Regression
#-------------------------------------------------

#No matter how significant a model can be we can still make it better by using
#Hypothesis testing so that all the co-efficients of variable are significant.
#If The below hypothesis holds true as the p-value(ethnicityafam):.78 > .05
#Null Hypothesis for X(Limit): H(1): coef(ethnicityafam)=0

#We can remove the ethnicity to construct a new model 
#which would have a much better significane

#Remove Ethnicity to construct the model
  
model2 <- glm(insurance ~ health+age+limit+gender+married+selfemp+family+region+education, family =binomial (link='logit'),data=training)
summary(model2)

#We can still observe insignificant variables whose 
#values are greater than .05. We'll apply null hypothesis testing again for model 2 and 
#see that P-value(regionmidwest)>.05. 

#Hence we remove region variable as well. 

#Model after removing region variable

model3 <- glm(insurance ~ health+age+limit+gender+married+selfemp+family+education, family =binomial (link='logit'),data=training)
summary(model3)

#We remove limit variable as well.

#Model after removing limit variable

model4 <- glm(insurance ~ health+age+gender+married+selfemp+family+education, family =binomial (link='logit'),data=training)
summary(model4)

#We can see that all the variables are significant, so model 4 is the potential model to 
#predcit the response variable. 

#-----------------------------------------------
#4.4 Partial F-test for Confidence Intervals 
#-----------------------------------------------
#For Alpha=.05
#We find the 95% probable interval from the 0.0 and 0.95 quantiles of the F distribution for 
#(6388,6401) degree of freedom for model 4

anova(model4)
lwr <- qf(0, 6388, model4$df.residual)
upr <- qf(0.95, 6388, model4$df.residual)
c(lwr, upr)

#So if the z-value falls outside this interval, we could decide that null Hypothesis as false
#and use alternative hypothesis. 

#Here are two Decision Rules based on the F distribution for our case using the pima dataset:
#Risk: a=0.05 Rule: If Z-Value falls within |1.042| Accept Null Hypothesis
#Risk: a=0.05 Rule: If Z-Value greater than |1.042| accept Alternative Hypothesis

#To see the z-value we use the summary() function:

summary(model4)

#It can be inferred that even in 5% of probable interval all the variables are significant to predict 
#the outcome as the z-value is not lying in the interval. Hence, alternative hypothesis is accepted which makes it a significant predictor. 
#Conclusion of the test with risk a=0.05 using the P-value


lwrpf <- pf(0, 6388, model4$df.residual)
uprpf <- pf(0.95, 6388, model4$df.residual)
c(lwrpf, uprpf)


#So if the P-value falls outside this interval, we could decide 
#that null Hypothesis H(1) and H(2) is false. 
#Here are two Decision Rules based on the F distribution
#for our case using the pima dataset:


#Risk: a=0.05 Rule: If P-value> .0209 Accept Null Hypothesis
#Risk: a=0.05 Rule: If P-value< .0209 Accept Alternate Hypothesis

#To see the p-value we use the summary() function:

summary(model4)

#Now It can be inferred that in 5% of probable interval all
#the variable are still significant predictor. 

#------------------------------------------------
#4.5 Test for Validating Models Significance
#------------------------------------------------

#Anova Test

anova(model1, test="Chisq")
anova(model2, test="Chisq")
anova(model3, test="Chisq")
anova(model4, test="Chisq")


#The difference between the null deviance and the residual deviance shows how significant model 
#is doing against the null model (a model with only the intercept).
#The wider this gap, the better which is the max for model 4.
#Analyzing the table we can see the increase in deviance when removing 
#each variable one at a time.
#We can see that it is a significant increase in deviance and
#the AIC as we go from model 1 to model 4.

---------------------------
#4.5 Potential Outliers
---------------------------

plot1 <- qplot(insurance, model4$fitted.values, geom = "boxplot", data=training)+labs(y="Fitted Values")+ggtitle("Residuals vs Test Plot")

#The Box Plot for insurance factor variable reveals a lot of outliers
#when compared with fitted values.

------------------
#4.6 ROC Curve
------------------
  
#To assess the predictive ability of the model we use ROC curve and calculate the AUC(Area under curve)
#which are typical performance measurementsfor a binary classifier.

pred<- predict(model4, training, type= 'response')
pred<- prediction(pred, training$insurance)
eval<- performance(pred,'tpr','fpr')
plot(eval, colorize = TRUE) 

#The ROC is a curve generated by plotting the true positive rate (TPR) against the false positive rate (FPR) at various threshold settings while the AUC is the area under the ROC curve.

----------------------------------------------------
#4.7 Assesing the predictive ability of the model
----------------------------------------------------

model.probs=predict(model4,training,type="response")

# misclassification error:train data
pred1<- ifelse(model.probs>0.5, 1, 0)
#Confusion Matrix 
tab1<- table(Predicted= pred1, Actual= training$insurance)

tab1
# misclassification error:train data
trainerror<- 1- sum(diag(tab1))/ sum(tab1)
trainerror
#Accuracy of Training data
print(paste('Accuracy',1-trainerror))


# Test Error
model.test=predict(model4,testing,type="response")

# misclassification error:test data
pred_test<- ifelse(model.test>0.5, 1, 0)
#Confusion Matrix 
tab_test<- table(Predicted= pred_test, Actual = testing$insurance)
tab_test
# misclassification error:test data
testerror<- 1- sum(diag(tab_test))/ sum(tab_test)
testerror
#Accuracy of Training data
print(paste('Accuracy',1-testerror))


#The error rate for training is roughly 19% and accuracy is 81.03% which is very high 
#compared to real time predictions. 
#After fitting the model with the testing data we can observe that the
#acccuracy is 80.833 % which indicates satisfactory goodness of fit of the model.  

#----------------------------
#4.8 Area Under the Curve
#----------------------------

auc<- performance(pred,"auc")
auc <- auc@y.values[[1]]
auc 

#As a rule of thumb, a model with good predictive ability should have an AUC closer to 1
#(1 is ideal) than to 0.5 which is the case with model 4 having area under the curve as .7486046.


#4.9 To Find the actual movement and predict whether person takes insurance or not

#To predict Direction for new values of Insurance we simply use the predict() function and
#feed in a data frame of new values. We want to predict Direction on a day when Lag1 and Lag2 equal 1.2 and 1.1, respectively,
#and on a day when they equal 1.5 and -0.8. 


predict(model4,newdata=data.frame(health= "yes",age=20,family=3,gender="female",education="bachelor",married="yes",selfemp="no"),
data=testing,type="response")

#As can be seen we can see the actual movement of whether the person has insurance or not by creating a
#new dataframe. Suppose a person walks into hospital with 

#health = yes

#age=20

#family=3

#gender=female

#education=bachelor

#married=yes

#selfemp=no

#Then ther are 92.38% prediction chance that she has insurance . 

#-------------------------------------------------------------------------------------------------------------
#5 Conclusion

#This feature can be widely used by the insurance companies to predict whether 
#the customer has health insurance or not.This would in turn help to infer the
#potential insurance buyers and help the companies to target the right audience to get maximum health insurance sales
#-------------------------------------------------------------------------------------------------