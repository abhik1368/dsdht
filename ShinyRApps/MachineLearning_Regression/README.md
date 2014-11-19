## Introduction ##

- This app is build from the Weight Lifting Exercise Dataset collected by Groupware@LES. For more information about the dataset, see their [website](http://groupware.les.inf.puc-rio.br/har). 

- The main description about my data preprocessing step is presented in my Practical Machine Learning Course Project [writeup](http://adason.github.io/Weight_Lifting_Exercise_ML/tree_based_prediction.html). 

- In this app, I would like to present the visualization of preprocessed data. Meanwhile, I will demostrate the parameter tuning of machine learning predictions using generalized linear model with `L1` (lasso) and `L2` (ridge) regularizations.

## Top Left Panel

- On the top left panel, you can choose changing the number of principle components that you want to use as features in machine leraning model. Including more principle components might slow down the app since you have to perform machine learning on bigger feature space.

- You can also choose the x-axis and the y-axis for plotting the dataset on the top right panel.

## Top Right Panel

- This panel is the scatter plot of `testing` dataset that was set aside for maching learning predictions. The x-axis and y-axis can be arbirary chosen. 

- Data points are color coded as their actual classes in testing dataset. On the other hand, the prediction color are used to enclose the actual calsses. If you didn't notice differernt color for each data point, that means our machine learning makes the prediction correctly.

## Bottom Left Panel

- In this panel, you can control the type of regularizaions that you want to incluse in the taining model. You can choose to perform just L1 regularization (lasso) or L2 regularization (ridge), or you can include both.

- You can choose the range of regularization parameters on the left panel as well. Different range might give you different best model. Try to choose differernt ranges to get the best accuracy!


## Bottom Right Panel

- This panel are separated into three tabs. 

- The first `Plot` tab includes the 5 repeated 5-fold cross validation training accuracy estimate of different tuning parameters (from your choice of the bottom left panel.)

- You can see the performace of the best model chosen from your cross-validated training models.

- The confusionmatrix will present the accuracy statistics and the predicted vs reference table of the testing dataset.

- You can also look as some details of your best model.
