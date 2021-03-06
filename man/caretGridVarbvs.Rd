% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/caret.R
\name{caretGridVarbvs}
\alias{caretGridVarbvs}
\title{Grid with varbvs for caret}
\usage{
caretGridVarbvs(x, y, len = NULL, search = "grid")
}
\arguments{
\item{x}{predictors}

\item{y}{outcome}

\item{len}{value of \code{tuneLength} that is potentially passed in through \code{train}}

\item{search}{either \code{"grid"} or \code{"random"}}
}
\value{
data frame of tuning parameter combinations with a column for each parameter
}
\description{
Grid with varbvs for caret
}
\author{
Timothee Flutre
}
