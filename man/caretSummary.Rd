% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/caret.R
\name{caretSummary}
\alias{caretSummary}
\title{Summary for caret}
\usage{
caretSummary(data, lev = NULL, model = NULL, plot = FALSE)
}
\arguments{
\item{data}{data frame with a column named \code{"obs"} and another named \code{"pred"}}

\item{lev}{levels (unused here)}

\item{model}{model (unused here)}

\item{plot}{if TRUE, observations regressed on predictions will be plotted}
}
\value{
vector with the root mean square error, variances of observations and predictions (if 0, most other metrics will be NA or NaN), Pearson and Spearman correlations between all data points, the 50\% best and the 25\% best, as well as the intercept, slope and determination coefficient of the simple linear regression \code{lm(obs ~ pred)} (\href{https://doi.org/10.1016/j.ecolmodel.2008.05.006}{Pineiro et al., 2008}), the statistic and p value for testing null bias (\href{https://tel.archives-ouvertes.fr/tel-00985747v2}{Baey, 2014, pages 52-53}), and the modelling efficiency (\href{https://doi.org/10.1016/0304-3800(93)90105-2}{Mayer and Butler, 1993})
}
\description{
Returns various metrics comparing predicted data with the values of the hold-out fold.
}
\examples{
\dontrun{set.seed(1859)
n <- 100

## without bias and low coef of determination
d <- data.frame(pred=rnorm(n=n, mean=30, sd=10))
d$obs <- 0 + 1 * d$pred + rnorm(n=n, mean=0, sd=8)
(out1 <- caretSummary(data=d, plot=TRUE))

## with bias and high coef of determination
d <- data.frame(pred=rnorm(n=n, mean=30, sd=10))
d$obs <- 10 + 0.5 * d$pred + rnorm(n=n, mean=0, sd=1)
(out2 <- caretSummary(data=d, plot=TRUE))
}
}
\author{
Timothee Flutre
}
