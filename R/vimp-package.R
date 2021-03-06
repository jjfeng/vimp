#' vimp: Perform Inference on Algorithm-Agnostic Variable Importance
#'
#' A unified framework for valid statistical inference on algorithm-agnostic
#' measures of variable importance. You provide the data, a method for 
#' estimating the conditional mean of the outcome given the covariates,
#' choose a variable importance measure, and specify variable(s) of interest;
#' 'vimp' takes care of the rest.
#' 
#' @section Author(s):
#' \bold{Maintainer}: Brian Williamson \url{http://bdwilliamson.github.io}
#' 
#' Methodology authors:
#' \itemize{
#'   \item{Brian D. Williamson}
#'   \item{Peter B. Gilbert}
#'   \item{Noah R. Simon}
#'   \item{Marco Carone}
#' }
#' 
#' @section See Also:
#' Preprints:
#' \itemize{
#'   \item{\url{http://biostats.bepress.com/uwbiostat/paper422/} (R-squared-based variable importance)}
#'   \item{\url{http://arxiv.org/abs/2004.03683} (general variable importance)}
#'   \item{\url{https://arxiv.org/abs/2006.09481} (general Shapley-based variable importance)}
#' }
#' 
#' Other useful links:
#' \itemize{
#'   \item{\url{http://bdwilliamson.github.io/vimp}}
#'   \item{\url{http://github.com/bdwilliamson/vimp}}
#'   \item{Report bugs at \url{http://github.com/bdwilliamson/vimp/issues}}
#' }
#' 
#' @section Imports:
#' The packages that we import either make the internal code nice (dplyr, magrittr, tibble, rlang, MASS), 
#' are directly relevant to estimating the conditional mean (SuperLearner) or predictiveness measures (ROCR), 
#' or are necessary for hypothesis testing (stats).
#' 
#' We suggest several other packages: xgboost, ranger, gam, glmnet, polspline, and quadprog allow 
#' a flexible library of candidate learners in the Super Learner; ggplot2, cowplot, 
#' and forcats help with plotting variable importance estimates; testthat and covr 
#' help with unit tests; and knitr, rmarkdown,
#' and RCurl help with the vignettes and examples.
#'
#' @docType package
#' @name vimp
NULL
