# Create Folds for Cross-Fitting
#
# @param y the outcome
# @param V the number of folds
# @param stratified should the folds be stratified based on the outcome?
# @param probs vector of proportions for each fold number
# @return a vector of folds
# @keywords internal
.make_folds <- function(y, V = 2, stratified = FALSE, probs = rep(1/V, V)) {
  folds <- vector("numeric", length(y))
  if (length(unique(probs)) == 1) {
    if (stratified) {
      folds_1 <- sample(rep(seq_len(V), length = sum(y == 1)))
      folds_0 <- sample(rep(seq_len(V), length = sum(y == 0)))
      folds[y == 1] <- folds_1
      folds[y == 0] <- folds_0
    } else {
      folds <- sample(rep(seq_len(V), length = length(y)))
    }
  } else {
    if (stratified) {
      folds_1 <- rep(seq_len(V), probs * sum(y == 1))
      folds_1 <- c(folds_1, sample(seq_len(V), size = sum(y == 1) - length(folds_1),
                                   replace = TRUE, prob = probs))
      folds_0 <- rep(seq_len(V), probs * sum(y == 0))
      folds_0 <- c(folds_0, sample(seq_len(V), size = sum(y == 0) - length(folds_0),
                                   replace = TRUE, prob = probs))
      folds_1 <- sample(folds_1)
      folds_0 <- sample(folds_0)
      folds[y == 1] <- folds_1
      folds[y == 0] <- folds_0
    } else {
      folds <- sample(rep(seq_len(V), probs * length(y)))
    }
  }
  return(folds)
}

# Run a Super Learner for the provided subset of features
#
# @param Y the outcome
# @param X the covariates
# @param V the number of folds
# @param SL.library the library of candidate learners
# @param s the subset of interest
# @param folds the CV folds
# @param verbose should we print progress? defaults to FALSE
# @param progress_bar the progress bar to print to (only if verbose = TRUE)
# @param indx the index to pass to progress bar (only if verbose = TRUE)
# @param ... other arguments to Super Learner
#
# @return a list of length V, with the results of predicting on the hold-out data for each v in 1 through V
# @keywords internal
run_sl <- function(Y, X, V, SL.library, univariate_SL.library, s, folds, 
                   verbose = FALSE, progress_bar = NULL, indx = 1, ...) {
  # if verbose, print what we're doing and make sure that SL is verbose
  L <- list(...)
  if (is.null(L$family)) {
    L$family <- gaussian()
  }
  if (is.null(L$obsWeights)) {
    L$obsWeights <- rep(1, length(Y))
  }
  if (verbose) {
    # message(paste0("Fitting regression for s = ", paste(s, collapse = ",")))
    if (is.null(L$cvControl)) {
      L$cvControl <- list(verbose = TRUE)
    } else if (grepl("verbose", names(L$cvControl))) {
      L$cvControl$verbose <- TRUE
    }
  }
  # fit the super learner on each full/reduced pair
  if (missing(folds)) {
    folds <- .make_folds(Y, V = V, stratified = (length(unique(Y)) == 2))
  }
  red_X <- as.data.frame(X[, s, drop = FALSE])
  this_sl_lib <- SL.library
  # if univariate regression (i.e., length(s) == 1) then check univariate_SL.library
  # if it exists, use it; otherwise, use the normal library
  if (length(s) == 1) {
    if (!is.null(univariate_SL.library)) {
      this_sl_lib <- univariate_SL.library
    }
    requires_2d <- c("glmnet", "polymars")
    for (i in 1:length(requires_2d)) {
      if (any(grepl(requires_2d[i], this_sl_lib)) & (ncol(red_X) == 1)) {
        red_X <- cbind.data.frame(V0 = 0, red_X)
      }
    }
  }
  fhat_ful <- list()
  fhat_red <- list()
  for (v in 1:V) {
    ## fit super learner
    this_L <- L
    this_L$obsWeights <- L$obsWeights[folds != v]
    new_arg_list <- c(list(Y = Y[folds != v, , drop = FALSE], X = red_X[folds != v, , drop = FALSE], SL.library = this_sl_lib), this_L)
    if (length(this_sl_lib) == 1) { # no need to do SL CV
      fit_library <- SuperLearner:::.createLibrary(this_sl_lib)
      fitter <- get(fit_library$library$predAlgorithm[1], envir = new_arg_list$env)
      fit <- fitter(Y = Y[folds != v, , drop = FALSE], X = red_X[folds != v, , drop = FALSE], newX = red_X[folds == v, , drop = FALSE],
                    family = new_arg_list$family, obsWeights = new_arg_list$obsWeights)
      fitted_v <- fit$fit
      fhat_ful[[v]] <- fit$pred
    } else {
      fit <- do.call(SuperLearner::SuperLearner, new_arg_list)
      fitted_v <- SuperLearner::predict.SuperLearner(fit)$pred
      ## get predictions on the validation fold
      fhat_ful[[v]] <- SuperLearner::predict.SuperLearner(fit, newdata = red_X[folds == v, , drop = FALSE])$pred  
    }
    
  }
  if (verbose) {
    setTxtProgressBar(progress_bar, indx)
  }
  return(list(preds = fhat_ful, folds = folds))
}

# release questions
# @keywords internal
release_questions <- function() {
  c(
    "Have you run cran_prep <- rhub::check_for_cran(env_vars = c(R_COMPILE_AND_INSTALL_PACKAGES = 'always'))?"
  )
}
