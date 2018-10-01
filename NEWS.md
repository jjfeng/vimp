# vimp 1.1.2

## Major changes

* added function `cv_vim_nodonsker`, which computes the cross-validated naive estimator and the update on the same, single, validation fold. This does not allow for relaxation of the Donsker class conditions.

## Minor changes

None

# vimp 1.1.1

## Major changes

* added function `two_validation_set_cv`, which sets up folds for V-fold cross-validation with two validation sets per fold
* changed the functionality of `cv_vim`: now, the cross-validated naive estimator is computed on a first validation set, while the update for the corrected estimator is computed using the second validation set (both created from `two_validation_set_cv`); this allows for relaxation of the Donsker class conditions necessary for asymptotic convergence of the corrected estimator, while making sure that the initial CV naive estimator is not biased high (due to a higher R^2 on the training data)

## Minor changes

None

# vimp 1.1.0

## Major changes

None

## Minor changes

* changed the functionality of `cv_vim`: now, the cross-validated naive estimator is computed on the training data for each fold, while the update for the corrected cross-validated estimator is computed using the test data; this allows for relaxation of the Donsker class conditions necessary for asymptotic convergence of the corrected estimator

# vimp 1.0.0

## Major changes

* removed function `vim`, replaced with individual-parameter functions 
* added function `vimp_regression` to match Python package
* `cv_vim` now can compute regression estimators
* renamed all internal functions; these are now `vimp_ci`, `vimp_se`, `vimp_update`, `onestep_based_estimator`
* edited vignette
* added unit tests

# vimp 0.0.3

## Major changes

None

## Minor changes

Bugfixes etc.