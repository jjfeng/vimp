#' Nonparametric Variable Importance Estimates: AUC
#'
#' Compute estimates of and confidence intervals for nonparametric difference in $AUC$-based variable importance. This is a wrapper function for \code{cv_vim}, with \code{type = "auc"}.
#'
#' @param Y the outcome.
#' @param X the covariates.
#' @param f1 the predicted values on validation data from a flexible estimation technique regressing Y on X in the training data; a list of length V, where each object is a set of predictions on the validation data.
#' @param f2 the predicted values on validation data from a flexible estimation technique regressing the fitted values in \code{f1} on X withholding the columns in \code{indx}; a list of length V, where each object is a set of predictions on the validation data.
#' @param indx the indices of the covariate(s) to calculate variable importance for; defaults to 1.
#' @param V the number of folds for cross-validation, defaults to 10.
#' @param folds the folds to use, if f1 and f2 are supplied.
#' @param stratified if run_regression = TRUE, then should the generated folds be stratified based on the outcome (helps to ensure class balance across cross-validation folds)
#' @param weights weights for the computed influence curve (e.g., inverse probability weights for coarsened-at-random settings)
#' @param run_regression if outcome Y and covariates X are passed to \code{cv_vim}, and \code{run_regression} is \code{TRUE}, then Super Learner will be used; otherwise, variable importance will be computed using the inputted fitted values.
#' @param SL.library a character vector of learners to pass to \code{SuperLearner}, if \code{f1} and \code{f2} are Y and X, respectively. Defaults to \code{SL.glmnet}, \code{SL.xgboost}, and \code{SL.mean}.
#' @param alpha the level to compute the confidence interval at. Defaults to 0.05, corresponding to a 95\% confidence interval.
#' @param delta the value of the \eqn{\delta}-null (i.e., testing if importance < \eqn{\delta}); defaults to 0.
#' @param na.rm should we remove NA's in the outcome and fitted values in computation? (defaults to \code{FALSE})
#' @param scale scale should CIs be computed on original ("identity") or logit ("logit") scale? (defaults to "identity")
#' @param ... other arguments to the estimation tool, see "See also".
#'
#' @return An object of classes \code{vim} and \code{vim_auc}. See Details for more information.
#'
#' @details AUC for each regression (full and reduced) is computed using \code{\link[ROCR]{performance}}.
#' In the interest of transparency, we return most of the calculations
#' within the \code{vim} object. This results in a list containing:
#' \itemize{
#'  \item{call}{ - the call to \code{vim}}
#'  \item{s}{ - the column(s) to calculate variable importance for}
#'  \item{SL.library}{ - the library of learners passed to \code{SuperLearner}}
#'  \item{full_fit}{ - the fitted values of the chosen method fit to the full data}
#'  \item{red_fit}{ - the fitted values of the chosen method fit to the reduced data}
#'  \item{est}{ - the estimated variable importance}
#'  \item{naive}{ - the naive estimator of variable importance}
#'  \item{update}{ - the influence curve-based update}
#'  \item{se}{ - the standard error for the estimated variable importance}
#'  \item{ci}{ - the \eqn{(1-\alpha) \times 100}\% confidence interval for the variable importance estimate}
#'  \item{full_mod}{ - the object returned by the estimation procedure for the full data regression (if applicable)}
#'  \item{red_mod}{ - the object returned by the estimation procedure for the reduced data regression (if applicable)}
#'  \item{alpha}{ - the level, for confidence interval calculation}
#'  \item{y}{ - the outcome}
#' }
#'
#' @examples
#' library(SuperLearner)
#' library(ranger)
#' ## generate the data
#' ## generate X
#' p <- 2
#' n <- 100
#' x <- data.frame(replicate(p, stats::runif(n, -1, 1)))
#'
#' ## apply the function to the x's
#' f <- function(x) 0.5 + 0.3*x[1] + 0.2*x[2]
#' smooth <- apply(x, 1, function(z) f(z))
#'
#' ## generate Y ~ Normal (smooth, 1)
#' y <- matrix(rbinom(n, size = 1, prob = smooth))
#'
#' ## set up a library for SuperLearner
#' learners <- "SL.ranger"
#'
#' ## estimate (with a small number of folds, for illustration only)
#' est <- vimp_auc(y, x, indx = 2,
#'            alpha = 0.05, run_regression = TRUE,
#'            SL.library = learners, V = 2, cvControl = list(V = 2))
#'
#' @seealso \code{\link[SuperLearner]{SuperLearner}} for specific usage of the \code{SuperLearner} function and package, and \code{\link[ROCR]{performance}} for specific usage of the \code{ROCR} package.
#' @export


vimp_auc <- function(Y, X, f1 = NULL, f2 = NULL, indx = 1, V = 10, weights = rep(1, length(Y)), run_regression = TRUE, SL.library = c("SL.glmnet", "SL.xgboost", "SL.mean"), alpha = 0.05, delta = 0, na.rm = FALSE, folds = NULL, stratified = TRUE, scale = "identity", ...) {
  cv_vim(Y = Y, X = X, f1 = f1, f2 = f2, indx = indx, V = V, weights = weights, type = "auc", run_regression = run_regression, SL.library = SL.library, alpha = alpha, delta = delta, na.rm = na.rm, folds = folds, stratified = stratified, scale = scale, ...)
}
