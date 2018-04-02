# Introduction to vimp
Brian D. Williamson  
`r Sys.Date()`  




Often when working with data we attempt to estimate the conditional mean of the outcome $Y$ given features $X$, defined as $\mu_P(x) = E_P(Y \mid X = x)$. 

There are many tools for estimating this conditional mean. We might choose a classical parametric tool such as linear regression. We might also want to be model-agnostic and use a more nonparametric approach to estimate the conditional mean. However, 

- This involves using some nonparametric smoothing technique, which requires: (1) choosing a technique, and (2) selecting tuning parameters
- Naive optimal tuning balances out the bias and variance of the smoothing estimator. Is this the correct trade-off for estimating the conditional mean?

Once we have a good estimate of the conditional mean, it is often of scientific interest to understand which features contribute the most to the variation in $\mu_P$. Specifically, we might consider \[\mu_{P, s}(x) = E_P(Y \mid X_{(-s)} = x_{(-s)}),\] where for a vector $v$ and a set of indices $s$, $v_{-(s)}$ denotes the elements of $v$ with index not in $s$. By comparing $\mu_{P, s}$ to $\mu_P$ we can evaluate the importance of the $s$th element (or group of elements).

Assume that our data are generated according to the mechanism $P_0$. We can then define a nonparametric measure of variable importance, \[\psi_{0, s} = \frac{\int [\mu_{P_0}(x) - \mu_{P_0, s}(x)]^2dP_0(x)}{\text{Var}_{P_0}(Y)},\] which is the proportion of the variability in the outcome explained by including $X_j$ in our chosen estimation technique. 

This document introduces you to the basic tools in vimp and how to apply them to a dataset. I will explore the two different ways of obtaining variable estimates using vimp:

1. You only specify a *library* of candidate estimators for the conditional means $\mu_{P_0}$ and $\mu_{P_0, s}$; you allow vimp to obtain the optimal estimates of these quantities using the `SuperLearner` [@vanderlaan2007], and use these estimates to obtain variable importance estimates
2. You have a favorite estimator for the conditional means; you simply want vimp to obtain variable importance estimates using this estimator

## A look at the Boston housing study data

Throughout this document I will use the Boston housing study data [@harrison1978], freely available from the `MASS` package. Use `?Boston` to see documentation for these data.


```r
## load the library, view the data
library(MASS)
data(Boston)
head(Boston)
```

```
##      crim zn indus chas   nox    rm  age    dis rad tax ptratio  black
## 1 0.00632 18  2.31    0 0.538 6.575 65.2 4.0900   1 296    15.3 396.90
## 2 0.02731  0  7.07    0 0.469 6.421 78.9 4.9671   2 242    17.8 396.90
## 3 0.02729  0  7.07    0 0.469 7.185 61.1 4.9671   2 242    17.8 392.83
## 4 0.03237  0  2.18    0 0.458 6.998 45.8 6.0622   3 222    18.7 394.63
## 5 0.06905  0  2.18    0 0.458 7.147 54.2 6.0622   3 222    18.7 396.90
## 6 0.02985  0  2.18    0 0.458 6.430 58.7 6.0622   3 222    18.7 394.12
##   lstat medv
## 1  4.98 24.0
## 2  9.14 21.6
## 3  4.03 34.7
## 4  2.94 33.4
## 5  5.33 36.2
## 6  5.21 28.7
```

In addition to the median house value `medv`, the outcome of interest, there are measurements on four groups of variables. First are accessibility features: the weighted distances to five employment centers in the Boston region `dis`, where housing prices are expected to increase with decreased distance to employment centers; and an index of accessibility to radial highways `rad`, where housing prices are expected to increase with increased access to highways. Second are neighborhood features: the proportion of black residents in the population `black`; the proportion of population that is lower status `lstat`, which denotes adults without some high school education and male workers classified as laborers; the crime rate `crim`; the proportion of a town's residential land zoned for lots greater than 25,000 square feet `zn`; the proportion of nonretail business acres per town `indus`; the full value property tax rate `tax`; the pupil-teacher ratio  by school district `ptratio`; and an indicator of whether the tract of land borders the Charles River `chas`. The third group are structural features: the average number of rooms in owner units `rm`; and the proportion of owner units built prior to 1940 `age`. The final group is the nitrogen oxide concentration `nox`. 

Since there are 13 features and four groups, it is of interest to determine variable importance both for the 13 features separately and for the four groups of features.

## A first approach: linear regression
Suppose that I believe that a linear model truly holds in the Boston housing data. In that case, I would be justified in only fitting a linear regression to estimate the conditional means; this means that in my importance analysis, I should also use only linear regression. This is achieved by the following:


```r
## estimate the full conditional mean using linear regression
full.mod <- lm(medv ~ ., data = Boston)
full.fit <- predict(full.mod)

## estimate the reduced conditional means for each of the individual variables
X <- as.matrix(Boston[, -14]) # remove the outcome for the predictor matrix

red.mod.crim <- lm(full.fit ~ X[,-1])
red.fit.crim <- predict(red.mod.crim)

red.mod.zn <- lm(full.fit ~ X[,-2])
red.fit.zn <- predict(red.mod.zn)

red.mod.indus <- lm(full.fit ~ X[,-3])
red.fit.indus <- predict(red.mod.indus)

red.mod.chas <- lm(full.fit ~ X[,-4])
red.fit.chas <- predict(red.mod.chas)

red.mod.nox <- lm(full.fit ~ X[,-5])
red.fit.nox <- predict(red.mod.nox)

red.mod.rm <- lm(full.fit ~ X[, -6])
red.fit.rm <- predict(red.mod.rm)

red.mod.age <- lm(full.fit ~ X[,-7])
red.fit.age <- predict(red.mod.age)

red.mod.dis <- lm(full.fit ~ X[, -8])
red.fit.dis <- predict(red.mod.dis)

red.mod.rad <- lm(full.fit ~ X[,-9])
red.fit.rad <- predict(red.mod.rad)

red.mod.tax <- lm(full.fit ~ X[,-10])
red.fit.tax <- predict(red.mod.tax)

red.mod.ptratio <- lm(full.fit ~ X[,-11])
red.fit.ptratio <- predict(red.mod.ptratio)

red.mod.black <- lm(full.fit ~ X[,-12])
red.fit.black <- predict(red.mod.black)

red.mod.lstat <- lm(full.fit ~ X[,-13])
red.fit.lstat <- predict(red.mod.lstat)

## load the library
library(vimp)

## plug these into vim
lm.vim.crim <- vim(full.fit, red.fit.crim, y = Boston$medv)
lm.vim.zn <- vim(full.fit, red.fit.zn, y = Boston$medv)
lm.vim.indus <- vim(full.fit, red.fit.indus, y = Boston$medv)
lm.vim.chas <- vim(full.fit, red.fit.chas, y = Boston$medv)
lm.vim.nox <- vim(full.fit, red.fit.nox, y = Boston$medv)
lm.vim.rm <- vim(full.fit, red.fit.rm, y = Boston$medv)
lm.vim.age <- vim(full.fit, red.fit.age, y = Boston$medv)
lm.vim.dis <- vim(full.fit, red.fit.dis, y = Boston$medv)
lm.vim.rad <- vim(full.fit, red.fit.rad, y = Boston$medv)
lm.vim.tax <- vim(full.fit, red.fit.tax, y = Boston$medv)
lm.vim.ptratio <- vim(full.fit, red.fit.ptratio, y = Boston$medv)
lm.vim.black <- vim(full.fit, red.fit.black, y = Boston$medv)
lm.vim.lstat <- vim(full.fit, red.fit.lstat, y = Boston$medv)

## make a table with the estimates using the merge_vim() function
lm.mat <- merge_vim(lm.vim.crim, lm.vim.zn, lm.vim.indus, lm.vim.chas,
                lm.vim.nox, lm.vim.rm, lm.vim.age, lm.vim.dis, lm.vim.rad,
                lm.vim.tax, lm.vim.ptratio, lm.vim.black, lm.vim.lstat)
## print out the matrix
lm.mat$mat
```

```
##                         est           se           cil          ciu
## lm.vim.lstat   5.643838e-02 2.279363e-02  0.0117636818 0.1011130864
## lm.vim.rm      4.380820e-02 1.694131e-02  0.0106038484 0.0770125548
## lm.vim.dis     2.885111e-02 7.474835e-03  0.0142007022 0.0435015157
## lm.vim.ptratio 2.795733e-02 6.834094e-03  0.0145627519 0.0413519065
## lm.vim.nox     1.140445e-02 4.755140e-03  0.0020845435 0.0207243480
## lm.vim.rad     1.121712e-02 4.348758e-03  0.0026937144 0.0197405309
## lm.vim.black   6.335620e-03 3.702814e-03 -0.0009217619 0.0135930026
## lm.vim.zn      6.027980e-03 3.608834e-03 -0.0010452051 0.0131011654
## lm.vim.crim    5.693839e-03 4.275991e-03 -0.0026869488 0.0140746263
## lm.vim.tax     5.671312e-03 2.484119e-03  0.0008025278 0.0105400962
## lm.vim.chas    5.126155e-03 4.834211e-03 -0.0043487238 0.0146010341
## lm.vim.indus   5.891587e-05 2.840487e-04 -0.0004978094 0.0006156412
## lm.vim.age     1.447559e-06 6.784973e-05 -0.0001315355 0.0001344306
```

## Building a library of learners

In general, we don't believe that a linear model truly holds. Thinking about potential model misspecification leads us to consider other algorithms. Suppose that I prefer to use generalized additive models [@hastie1990] to estimate $\mu_{P_0}$ and $\mu_{P_0, s}$, so I am planning on using the `gam` package. Suppose that you prefer to use the elastic net [@zou2005], and are planning to use the `glmnet` package. 

The choice of either method is somewhat subjective, and I also will have to use a technique like cross-validation to determine an optimal tuning parameter in each case. It is also possible that neither additive models nor the elastic net will do a good job estimating the true conditional means! 

This motivates using `SuperLearner` to allow the data to determine the optimal combination of *base learners* from a *library* that I define. These base learners are a combination of different methods (e.g., generalized additive models and elastic net) and instances of the same method with different tuning parameter values (e.g., additive models with 3 and 4 degrees of freedom). The Super Learner is an example of model stacking, or model aggregation --- these approaches use a data-adaptive combination of base learners to make predictions. 

For instance, my library could include additive models, elastic net , random forests [@breiman2001], and gradient boosted trees [@friedman2001] as follows:


```r
## load the library
library(SuperLearner)
```

```
## Loading required package: nnls
```

```
## Super Learner
```

```
## Version: 2.0-23-9000
```

```
## Package created on 2017-11-29
```

```r
## create a function for boosted stumps
SL.gbm.1 <- function(..., interaction.depth = 1) SL.gbm(..., interaction.depth = interaction.depth)

## create GAMs with different degrees of freedom
SL.gam.3 <- function(..., deg.gam = 3) SL.gam(..., deg.gam = deg.gam)
SL.gam.4 <- function(..., deg.gam = 4) SL.gam(..., deg.gam = deg.gam)
SL.gam.5 <- function(..., deg.gam = 5) SL.gam(..., deg.gam = deg.gam)

## add more levels of alpha for glmnet
create.SL.glmnet <- function(alpha = c(0.25, 0.5, 0.75)) {
  for (mm in seq(length(alpha))) {
    eval(parse(file = "", text = paste('SL.glmnet.', alpha[mm], '<- function(..., alpha = ', alpha[mm], ') SL.glmnet(..., alpha = alpha)', sep = '')), envir = .GlobalEnv)
  }
  invisible(TRUE)
}
create.SL.glmnet()

## add tuning parameters for randomForest
create.SL.randomForest <- function(tune = list(mtry = c(1, 5, 7), nodesize = c(1, 5, 10))) {
  tuneGrid <- expand.grid(tune, stringsAsFactors = FALSE)
  for (mm in seq(nrow(tuneGrid))) {
    eval(parse(file = "", text = paste("SL.randomForest.", mm, "<- function(..., mtry = ", tuneGrid[mm, 1], ", nodesize = ", tuneGrid[mm, 2], ") SL.randomForest(..., mtry = mtry, nodesize = nodesize)", sep = "")), envir = .GlobalEnv)
  }
  invisible(TRUE)
}
create.SL.randomForest()

## create the library
learners <- c("SL.gam", "SL.gam.3", "SL.gam.4", "SL.gam.5",
              "SL.glmnet", "SL.glmnet.0.25", "SL.glmnet.0.5", "SL.glmnet.0.75",
              "SL.randomForest", "SL.randomForest.1", "SL.randomForest.2", "SL.randomForest.3",
              "SL.randomForest.4", "SL.randomForest.5", "SL.randomForest.6", "SL.randomForest.7",
              "SL.randomForest.8", "SL.randomForest.9",
              "SL.gbm.1")
```

Now that I have created the library of learners, I can move on to estimating variable importance.

## Estimating variable importance for a single variable

The main function in the vimp package is the `vim()` function. There are three main arguments to `vim()`:

- `f1` and `f2`, which specify whether or not I need to estimate the conditional means 
- `data`, which supplies data to the function
- `s`, which determines the feature I want to estimate variable importance for

There are three ways to specify `f1` and `f2`:

1. Use formula notation and supply a library of learners (e.g., `learners` above)
2. Supply fitted values for our estimate of $\mu_{P_0}$ but supply a library of learners for estimating $\mu_{P_0, s}$
3. Supply fitted values for both estimates

I will illustrate each of these choices in order below, but in general I use (1) to estimate variable importance for the first feature in a given dataset and (2) or (3) to estimate variable importance for subsequent features in the same dataset. Method (3) allows the most flexibility, and all time-intensive computation occurs before calling `vim()`; however, this involves more work on your end. 

Suppose that the first feature that I want to estimate variable importance for is nitrogen oxide, `nox`. Since this is the first feature, say I choose (1) above. Then supplying `vim()` with 

- `f1 = y ~ x`
- `f2 = fit ~ x`
- `data = Boston`
- `indx = 5` 

means that: 

- I want to use `SuperLearner()` to estimate the conditional mean $\mu_{P_0}$
- I want to use the sequential regression procedure outlined in [@williamson2017] to estimate the conditional mean $\mu_{P_0, s}$
- I want to estimate variable importance for the fifth column of `Boston`, which is `nox`

The call to `vim()` looks like this:

```r
## load the library
library(vimp)

## first re-order the data so that the outcome is in the first column
Boston2 <- Boston[, 1:13]
Boston3 <- cbind(medv = Boston$medv, Boston2)

## now estimate variable importance
vim(f1 = y ~ x, f2 = fit ~ x, data = Boston3, y = Boston3[, 1], 
    indx = 5, SL.library = learners)
```

While this is the preferred method for estimating variable importance, using a large library of learners may cause the function to take time to run. Usually this is okay --- in general, you took a long time to collect the data, so letting an algorithm run for a few hours should not be an issue. 

However, for the sake of illustration, I can estimate varibable importance for nitrogen oxide only using only two base learners as follows:

```r
## load the library
library(vimp)

## first re-order the data so that the outcome is in the first column
Boston2 <- Boston[, 1:13]
Boston3 <- cbind(medv = Boston$medv, Boston2)

## new learners library, with only one learner for illustration only
learners.2 <- c("SL.gam", "SL.glmnet")

## now estimate variable importance
nox.vim <- vim(f1 = y ~ x, f2 = fit ~ x, data = Boston3, y = Boston3$medv, indx = 5, SL.library = learners.2)
```

```
## Loading required package: gam
```

```
## Loading required package: splines
```

```
## Loading required package: foreach
```

```
## Loaded gam 1.14-4
```

```
## Loading required package: glmnet
```

```
## Loading required package: Matrix
```

```
## Loaded glmnet 2.0-10
```

This code takes approximately 11 seconds to run on a (not very fast) PC. Under the hood, `vim()` fits the `SuperLearner()` function with the specified library, and then returns fitted values and variable importance estimates. This is most suitable for estimating variable importance for the first feature on a given dataset. I can display these estimates:


```r
nox.vim
```

```
## Call:
## vim(f1 = y ~ x, f2 = fit ~ x, data = Boston3, y = Boston3$medv, 
##     indx = 5, SL.library = learners.2)
## 
## Variable importance estimates:
##       Estimate   SE          95% CI                  
## s = 5 0.03887025 0.006336587 [0.02645077, 0.05128973]
```

The object returned by `vim()` also contains fitted values from using `SuperLearner()`; I access these using `$full.fit` and `$red.fit`. For example,


```r
head(nox.vim$full.fit)
```

```
##       [,1]
## 1 28.73662
## 2 23.44149
## 3 31.62415
## 4 31.50261
## 5 30.04405
## 6 26.68196
```

```r
head(nox.vim$red.fit)
```

```
##       [,1]
## 1 30.10768
## 2 24.05180
## 3 31.72481
## 4 31.43526
## 5 30.15800
## 6 26.91924
```

I said earlier that I want to obtain estimates of all individual features in these data, so let's choose average number of rooms (`rm`) next. Now that I have estimated variable importance for nitrogen oxide, the `full.fit` object contains our estimate of $\mu_{P_0}$. Since I have spent the time to estimate this using `SuperLearner()`, there is no reason to estimate this function again. This leads me to choose (2) above, since I have already estimated variable importance on one feature in this dataset. Using the small learners library (again only for illustration) yields


```r
## specify that full.fit doesn't change
full.fit <- nox.vim$full.fit

## estimate variable importance for the average number of rooms
rm.vim <- vim(full.fit, f2 = fit ~ x, data = Boston3, y = Boston3$medv,
              indx = 6, SL.library = learners.2)

rm.vim
```

```
## Call:
## vim(f1 = full.fit, f2 = fit ~ x, data = Boston3, y = Boston3$medv, 
##     indx = 6, SL.library = learners.2)
## 
## Variable importance estimates:
##       Estimate   SE         95% CI                  
## s = 6 0.07007819 0.01566228 [0.03938069, 0.10077569]
```

This takes approximately 5 seconds --- now rather than estimating both conditional means, I am only estimating one.

If I choose (3), then I have to use a single method from the library, or call `SuperLearner()` ourselves, prior to estimating variable importance. Then `vim()` returns variable importance estimates based on these fitted values. For example, let's estimate variable importance for the distance to radial highways using this approach.


```r
## set up the data
y <- Boston$medv
x <- Boston[, -c(8, 14)] # this removes dis and medv

## fit a GAM and glmnet using SuperLearner, using the two-step estimating procedure
reduced.mod <- SuperLearner(Y = full.fit, X = x, SL.library = learners.2)
reduced.fit <- predict(reduced.mod)$pred
## this takes 2 seconds

## estimate variable importance
dis.vim <- vim(full.fit, reduced.fit, y = Boston3$medv, indx = 8)
```

It is important to note that if I use the same learners library, then approaches (2) and (3) are equivalent. 

I can obtain estimates for the remaining individual features in the same way (again using only two base learners for illustration):

```r
crim.vim <- vim(full.fit, fit ~ x, data = Boston3, y = Boston3$medv,
                indx = 1, SL.library = learners.2)
zn.vim <- vim(full.fit, fit ~ x, data = Boston3, y = Boston3$medv,
                indx = 2, SL.library = learners.2)
indus.vim <- vim(full.fit, fit ~ x, data = Boston3, y = Boston3$medv,
                indx = 3, SL.library = learners.2)
chas.vim <- vim(full.fit, fit ~ x, data = Boston3, y = Boston3$medv,
                indx = 4, SL.library = learners.2)
age.vim <- vim(full.fit, fit ~ x, data = Boston3, y = Boston3$medv,
                indx = 7, SL.library = learners.2)
rad.vim <- vim(full.fit, fit ~ x, data = Boston3, y = Boston3$medv,
                indx = 9, SL.library = learners.2)
tax.vim <- vim(full.fit, fit ~ x, data = Boston3, y = Boston3$medv,
                indx = 10, SL.library = learners.2)
ptratio.vim <- vim(full.fit, fit ~ x, data = Boston3, y = Boston3$medv,
                indx = 11, SL.library = learners.2)
black.vim <- vim(full.fit, fit ~ x, data = Boston3, y = Boston3$medv,
                indx = 12, SL.library = learners.2)
lstat.vim <- vim(full.fit, fit ~ x, data = Boston3, y = Boston3$medv,
                indx = 13, SL.library = learners.2)
```

Now that I have estimates of each of individual feature's variable importance, I can view them all simultaneously by plotting:

```r
## combine the objects together
ests <- merge_vim(crim.vim, zn.vim, indus.vim, chas.vim,
                nox.vim, rm.vim, age.vim, dis.vim, rad.vim,
                tax.vim, ptratio.vim, black.vim, lstat.vim)

## create a vector of names; must be in the same order as the
## mat object in ests
nms <- c("Prop. lower status", "Avg. num. rooms", "Pupil-teacher ratio", "Nitrogen oxide", "Distance", "Crime", "Access to radial hwys", "Property tax rate", "Charles riv.", "Prop. black", "Prop. business", "Prop. large zoned", "Age")

## plot
plot(ests, nms, pch = 16, ylab = "", xlab = "Estimate", main = "Estimated variable importance for individual features", xlim = c(0, 0.2), axes = FALSE)
```

```
## Warning in plot.xy(xy.coords(x, y), type = type, ...): "axes" is not a
## graphical parameter
```

```
## Warning in graphics::axis(side = 2, at = 1:dim(ord.mat)[1], label =
## y[order(ord.mat$est)], : "axes" is not a graphical parameter
```

```
## Warning in graphics::axis(side = 1, at = seq(xlim[1], xlim[2], xlim[2]/
## 10), : "axes" is not a graphical parameter
```

![](introduction_files/figure-html/unnamed-chunk-13-1.png)<!-- -->

## Estimating variable importance for a group of variables

Now that I have estimated variable importance for each of the individual features, I can estimate variable importance for each of the groups that I mentioned above: accessibility features, structural features, nitrogen oxide, and neighborhood features.

The only difference between estimating variable importance for a group of features rather than an individual feature is that now I specify a vector for `s`; I can use any of the options listed in the previous section to compute these estimates.


```r
## get the estimates
structure.vim <- vim(full.fit, fit ~ x, data = Boston3, y = Boston3$medv,
                indx = c(6, 7), SL.library = learners.2)
access.vim <- vim(full.fit, fit ~ x, data = Boston3, y = Boston3$medv,
                indx = c(8, 9), SL.library = learners.2)
neigh.vim <- vim(full.fit, fit ~ x, data = Boston3, y = Boston3$medv,
                indx = c(1, 2, 3, 4, 10, 11, 12, 13), SL.library = learners.2)

## combine and plot
groups <- merge_vim(structure.vim, access.vim, neigh.vim, nox.vim)
nms.2 <- c("Neighborhood", "Structure", "Accessibility", "Nitrogen oxide")
plot(groups, nms.2, pch = 16, ylab = "", xlab = "Estimate", main = "Estimated variable importance for groups", xlim = c(0, 0.5), axes = FALSE)
```

```
## Warning in plot.xy(xy.coords(x, y), type = type, ...): "axes" is not a
## graphical parameter
```

```
## Warning in graphics::axis(side = 2, at = 1:dim(ord.mat)[1], label =
## y[order(ord.mat$est)], : "axes" is not a graphical parameter
```

```
## Warning in graphics::axis(side = 1, at = seq(xlim[1], xlim[2], xlim[2]/
## 10), : "axes" is not a graphical parameter
```

![](introduction_files/figure-html/unnamed-chunk-14-1.png)<!-- -->

## References