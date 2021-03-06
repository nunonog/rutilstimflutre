% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/stats.R
\name{adjustThreshSidak}
\alias{adjustThreshSidak}
\title{Multiple testing}
\usage{
adjustThreshSidak(nbPvals, thresh = 0.05)
}
\arguments{
\item{nbPvals}{number of p values (without NA's)}

\item{thresh}{nominal significance threshold on the familywise error rate (FWER)}
}
\value{
numeric
}
\description{
Return the significance threshold adjusted according to the Sidak correction.
}
\seealso{
\code{\link{adjustThreshBonf}}
}
\author{
Timothee Flutre
}
