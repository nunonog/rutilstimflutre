## Contains functions useful for spatial statistics.

##' AR1xAR1 simulation
##'
##' Simulate random samples from a separable AR1xAR1 process as in \href{https://dx.doi.org/10.1016/0378-3758(95)00066-6}{Martin (1996)}.
##' @param n number of samples
##' @param R number of rows
##' @param C number of columns
##' @param rho.r correlation between rows
##' @param rho.c correlation between columns
##' @param sigma.X.2 variance of X (see Martin, 1996, page 400)
##' @param sigma.e.2 variance of epsilons (see Martin, 1996, page 400)
##' @return array which first dimension is R, second is C and third is n
##' @author Timothee Flutre
##' @examples
##' \dontrun{## strong correlation only between rows
##' set.seed(1234)
##' samples <- simulAr1Ar1(n=100, R=40, C=45, rho.r=0.8, rho.c=0)
##' dim(samples)
##' stats <- list()
##' stats$cor.btw.rows <- c(apply(samples, 3, function(mat){
##'   apply(mat, 2, function(row.i){ # per column
##'     acf(row.i, lag.max=1, type="correlation", plot=FALSE)$acf[2]
##' })}))
##' stats$cor.btw.cols <- c(apply(samples, 3, function(mat){
##'   apply(mat, 1, function(col.j){ # per row
##'     acf(col.j, lag.max=1, type="correlation", plot=FALSE)$acf[2]
##' })}))
##' sapply(stats, summary)
##'
##' ## strong correlation only between columns
##' set.seed(1234)
##' samples <- simulAr1Ar1(n=100, R=40, C=45, rho.r=0, rho.c=0.8)
##' stats <- list()
##' stats$cor.btw.rows <- c(apply(samples, 3, function(mat){
##'   apply(mat, 2, function(row.i){ # per column
##'     acf(row.i, lag.max=1, type="correlation", plot=FALSE)$acf[2]
##' })}))
##' stats$cor.btw.cols <- c(apply(samples, 3, function(mat){
##'   apply(mat, 1, function(col.j){ # per row
##'     acf(col.j, lag.max=1, type="correlation", plot=FALSE)$acf[2]
##' })}))
##' sapply(stats, summary)
##'
##' ## strong correlation between rows and between columns
##' set.seed(1234)
##' samples <- simulAr1Ar1(n=100, R=40, C=45, rho.r=0.8, rho.c=0.8)
##' stats <- list()
##' stats$cor.btw.rows <- c(apply(samples, 3, function(mat){
##'   apply(mat, 2, function(row.i){ # per column
##'     acf(row.i, lag.max=1, type="correlation", plot=FALSE)$acf[2]
##' })}))
##' stats$cor.btw.cols <- c(apply(samples, 3, function(mat){
##'   apply(mat, 1, function(col.j){ # per row
##'     acf(col.j, lag.max=1, type="correlation", plot=FALSE)$acf[2]
##' })}))
##' sapply(stats, summary)
##'
##' ## low correlation between rows and strong correlation between columns
##' set.seed(1234)
##' samples <- simulAr1Ar1(n=100, R=40, C=45, rho.r=0.2, rho.c=0.8)
##' stats <- list()
##' stats$cor.btw.rows <- c(apply(samples, 3, function(mat){
##'   apply(mat, 2, function(row.i){ # per column
##'     acf(row.i, lag.max=1, type="correlation", plot=FALSE)$acf[2]
##' })}))
##' stats$cor.btw.cols <- c(apply(samples, 3, function(mat){
##'   apply(mat, 1, function(col.j){ # per row
##'     acf(col.j, lag.max=1, type="correlation", plot=FALSE)$acf[2]
##' })}))
##' sapply(stats, summary)
##'
##' ## low correlation between rows and strong correlation between columns
##' ## AND high error variance
##' set.seed(1234)
##' samples <- simulAr1Ar1(n=100, R=40, C=45, rho.r=0.2, rho.c=0.8,
##'                        sigma.X.2=1, sigma.e.2=200)
##' stats <- list()
##' stats$cor.btw.rows <- c(apply(samples, 3, function(mat){
##'   apply(mat, 2, function(row.i){ # per column
##'     acf(row.i, lag.max=1, type="correlation", plot=FALSE)$acf[2]
##' })}))
##' stats$cor.btw.cols <- c(apply(samples, 3, function(mat){
##'   apply(mat, 1, function(col.j){ # per row
##'     acf(col.j, lag.max=1, type="correlation", plot=FALSE)$acf[2]
##' })}))
##' sapply(stats, summary)
##' }
##' @export
simulAr1Ar1 <- function(n=1, R=2, C=2, rho.r=0, rho.c=0,
                        sigma.X.2=1, sigma.e.2=1){
  stopifnot(R > 1,
            C > 1,
            abs(rho.r) <= 1,
            abs(rho.c) <= 1,
            sigma.X.2 >= 0,
            sigma.e.2 > 0)

  N <- n

  ## sample all errors
  epsilons <- array(data=stats::rnorm(n=R*C*N, mean=0, sd=sqrt(sigma.e.2)),
                    dim=c(R, C, N))

  tmp <- lapply(1:N, function(n){
    X <- matrix(data=NA, nrow=R, ncol=C)

    ## first cell
    X[1, 1] <- sqrt(sigma.X.2 / sigma.e.2) * epsilons[1, 1, n]

    ## cells of the first row
    for(j in 2:C)
      X[1, j] <- rho.c * X[1, j-1] +
        sqrt((1 - rho.c^2) * sigma.X.2 / sigma.e.2) * epsilons[1, j, n]

    ## cells of the first column
    for(i in 2:R)
      X[i, 1] <- rho.r * X[i-1, 1] +
        sqrt((1 - rho.r^2) * sigma.X.2 / sigma.e.2) * epsilons[i, 1, n]

    ## remaining cells (equation 5 of Martin, 1996)
    for(i in 2:R)
      for(j in 2:C)
        X[i, j] <- rho.r * X[i-1, j] +
          rho.c * X[i, j-1] -
          rho.r * rho.c * X[i-1, j-1] +
          epsilons[i, j, n]

    return(X)
  })

  x <- array(data=do.call(c, tmp),
             dim=c(R, C, N))

  return(x)
}

##' Correct spatial heterogeneity
##'
##' Use kriging to correct spatial heterogeneity in a plant field trial.
##' Kriging (i.e. prediction) is performed per year.
##' Then, the predicted responses that controls would have had if they had been planted everywhere are subtracted from the observed responses from the other genotypes.
##' @param dat data frame with, at least, columns named "geno", "control" (TRUE/FALSE), "rank", "location", "year" and <response>
##' @param response column name of dat corresponding to the response for which spatial heterogeneity will be corrected
##' @param fix.eff if not NULL, vector of column names of data corresponding to fixed effects to control for in the kriging (e.g. "block")
##' @param min.ctls.per.year minimum number of control data points in a given year to proceed
##' @param cressie if TRUE, the variogram function from the gstat package uses Cressie's robust variogram estimate, else it uses the classical method of moments
##' @param vgm.model type(s) of variogram model(s) given to the vgm function of the gstat package; if several, the best one (smaller sum of squared errors) will be used
##' @param nb.folds number of folds for the cross-validation
##' @param out.prefix prefix of the output files to save plots and results (if not NULL)
##' @param verbose verbosity level (0/1/2)
##' @return data frame as dat but with an additional column named <response>.csh
##' @author Timothee Flutre
##' @export
correctSpatialHeterogeneity <- function(dat,
                                        response,
                                        fix.eff=NULL,
                                        min.ctls.per.year=10,
                                        cressie=TRUE,
                                        vgm.model=c("Exp", "Sph", "Gau", "Ste"),
                                        nb.folds=5,
                                        out.prefix=NULL,
                                        verbose=1){
  requireNamespace("sp")
  requireNamespace("gstat")
  if(verbose > 0)
    requireNamespace("lattice")
  stopifnot(is.data.frame(dat),
            "geno" %in% colnames(dat),
            "control" %in% colnames(dat),
            "rank" %in% colnames(dat),
            "location" %in% colnames(dat),
            "year" %in% colnames(dat),
            is.character(response),
            response %in% colnames(dat),
            is.logical(cressie),
            is.character(vgm.model))
  if(! is.null(fix.eff)){
    stopifnot(is.character(fix.eff))
    if("1" %in% fix.eff)
      fix.eff <- fix.eff[-grep("1", fix.eff)]
    if("year" %in% fix.eff){
      msg <- "'year' is removed from fix.eff"
      warning(msg)
      fix.eff <- fix.eff[-grep("year", fix.eff)]
    }
    if(length(fix.eff) == 0){
      fix.eff <- NULL
    } else
      for(fix.eff.i in fix.eff)
        stopifnot(fix.eff.i %in% colnames(dat))
  }
  for(x in c("rank", "location")){
    if(is.factor(dat[[x]])){
      if(mode(dat[[x]]) != "numeric"){
        msg <- paste0("mode(dat$", x, ") should be 'numeric'")
        stop(msg)
      }
      dat[[x]] <- as.numeric(levels(dat[[x]]))[dat[[x]]]
    }
  }

  ## prepare output
  out <- dat
  new.col <- paste0(response, ".csh") # csh="corrected for spatial heterogeneity"
  out[[new.col]] <- 0

  for(year in levels(dat$year)){
    ## set up objects for control and panel data
    cols.tokeep <- c("geno",
                     "rank", "location",
                     "year",
                     fix.eff,
                     response)
    inFctResp <- inlineFctForm(response)
    if(! all(is.na(inFctResp[[response]])))
      cols.tokeep <- c(cols.tokeep,
                       inFctResp[[response]][1])
    dat.ctl <- droplevels(dat[dat$control & dat$year == year,
                              cols.tokeep])
    dat.ctl.noNA <- stats::na.omit(dat.ctl)
    if(nrow(dat.ctl.noNA) <= min.ctls.per.year){
      msg <- paste0("skip year '", year, "' because not enough control data")
      write(msg, stdout())
      next
    }
    locs <- paste0(dat.ctl.noNA$rank, "_", dat.ctl.noNA$location)
    if(anyDuplicated(locs)){
      msg <- paste0("in ", year, " krige.cv and krige from gstat",
                    " don't work with duplicated locations")
      stop(msg)
    }
    dat.ctl.noNA.sp <-
      sp::SpatialPointsDataFrame(
              coords=dat.ctl.noNA[, c("rank","location")],
              data=dat.ctl.noNA[, -grep("rank|location",
                                        colnames(dat.ctl.noNA))])
    dat.panel <- droplevels(dat[! dat$control & dat$year == year,
                                cols.tokeep])
    colnames(dat.panel)[colnames(dat.panel) == response] <-
      paste0(response, ".raw")
    dat.panel.sp <-
      sp::SpatialPointsDataFrame(
              coords=dat.panel[, c("rank","location")],
              data=dat.panel[, -grep("rank|location",
                                     colnames(dat.panel))])
    dat.all <- droplevels(dat[dat$year == year,
                              cols.tokeep])
    colnames(dat.all)[colnames(dat.all) == response] <-
      paste0(response, ".raw")
    dat.all.sp <-
      sp::SpatialPointsDataFrame(
              coords=dat.all[, c("rank","location")],
              data=dat.all[, -grep("rank|location",
                                   colnames(dat.all))])

    if(verbose > 0){
      msg <- paste0("compute experimental variogram on control data",
                    " in ", year, "...")
      write(msg, stdout())
    }
    form <- paste0(response, " ~ 1")
    if(! is.null(fix.eff))
      form <- paste0(form, " + ", paste(fix.eff, collapse=" + "))
    if(verbose > 0){
      msg <- paste0("kriging formula in ", year, ":\n", form)
      write(msg, stdout())
    }
    vg.c <- gstat::variogram(object=stats::formula(form),
                             locations=~ rank + location,
                             data=dat.ctl.noNA,
                             cloud=TRUE, cressie=cressie)
    if(verbose > 1)
      print(graphics::plot(vg.c,
                           main=paste0(response,
                                       ": variogram cloud of controls",
                                       " in ", year)))
    vg <- gstat::variogram(object=stats::formula(form),
                           locations=~ rank + location,
                           data=dat.ctl.noNA,
                           cloud=FALSE, cressie=cressie)
    if(verbose > 1)
      print(graphics::plot(vg,
                           main=paste0(response, ": variogram of controls",
                                       " in ", year)))

    if(verbose > 0){
      msg <- paste0("fit variogram model on control data in ", year, "...")
      write(msg, stdout())
    }
    ## Help:
    ## gstat::vgm()
    ## gstat::show.vgms()
    vg.fit <- suppressWarnings(
        gstat::fit.variogram(object=vg,
                             model=gstat::vgm(vgm.model),
                             fit.sills=TRUE,
                             fit.ranges=TRUE,
                             fit.kappa=seq(0.3, 5, 0.05)))
    if(verbose > 0){
      print(vg.fit)
      msg <- paste0("sum of squared errors: ",
                    round(attr(vg.fit, "SSErr"), 3))
      write(msg, stdout())
    }
    for(i in 1:2){
      if(all(! is.null(out.prefix), i == 2)){
        p2f <- paste0(out.prefix, "_plot-vg-ctl-fit_", year, ".pdf")
        grDevices::pdf(file=p2f, paper="a4")
      }
      if((i == 1 & verbose > 1) | i == 2)
        print(graphics::plot(vg, vg.fit, main="", col="blue",
                             key=list(space="top", lines=list(col="blue"),
                                      text=list(paste0(response,
                                                       ": fit of variogram model",
                                                       " (", vg.fit[2, "model"], ")",
                                                       " on controls in ",
                                                       year)))))
      if(all(! is.null(out.prefix), i == 2))
        grDevices::dev.off()
    }

    if(verbose > 0){
      msg <- paste0("assess prediction accuracy by ",
                    nb.folds, "-fold cross-validation in ", year, "...")
      write(msg, stdout())
    }
    cv.k <- gstat::krige.cv(formula=stats::formula(form),
                            locations=dat.ctl.noNA.sp,
                            model=vg.fit,
                            nfold=nb.folds,
                            ## nfold=nrow(dat.ctl.noNA.sp), # LOO
                            verbose=ifelse(verbose > 1, TRUE, FALSE))
    ## print(summary(cv.k))
    cv.k.dat <- as.data.frame(cv.k)
    if(verbose > 0)
      print(c("RMSE"=sqrt(mean(cv.k.dat$residual^2)),
              "bias"=mean(cv.k.dat$residual),
              "MSDR"=mean(cv.k.dat$residual^2 / cv.k.dat$var1.var),
              "corObsPred"=stats::cor(cv.k.dat$observed, cv.k.dat$observed - cv.k.dat$residual),
              "corObsRes"=stats::cor(cv.k.dat$observed - cv.k.dat$residual, cv.k.dat$residual)))
    if(verbose > 1){
      print(sp::spplot(obj=cv.k, zcol="residual", scales=list(draw=TRUE),
                       xlab="ranks", ylab="locations",
                       main=paste0("Cross-validation residuals of predicted values",
                                   " of the control in ", year),
                       key.space="right", aspect="fill"))
      print(sp::bubble(obj=cv.k, zcol="residual", scales=list(draw=TRUE),
                       xlab="ranks", ylab="locations",
                       main=paste0("Cross-validation residuals of predicted values",
                                   " of the control in ", year),
                       key.space="right", aspect="fill"))
    }

    if(verbose > 0){
      msg <- paste0("prediction (kriging) of control data on panel coords",
                    " in ", year, "...")
      write(msg, stdout())
    }
    k <- gstat::krige(formula=stats::formula(form),
                      locations=dat.ctl.noNA.sp,
                      # newdata=dat.panel.sp,
                      newdata=dat.all.sp,
                      model=vg.fit,
                      debug.level=0)
    ## print(summary(k))
    if(verbose > 1)
      print(sp::spplot(obj=k, zcol="var1.pred", scales=list(draw=TRUE),
                       xlab="ranks", ylab="locations",
                       main=paste0("Predicted values of the control",
                                   " in ", year),
                       key.space="right", aspect="fill"))

    if(verbose > 0){
      msg <- paste0("correct panel data with the predicted values",
                    " of the controls in ", year, "...")
      write(msg, stdout())
    }
    k.coords <- sp::coordinates(k)
    k.dat <- as.data.frame(k)
    for(i in 1:nrow(k)){
      rank <- k.coords[i, "rank"]
      loc <- k.coords[i, "location"]
      out.idx <- which(out$rank == rank &
                       out$location == loc &
                       out$year == year)
      stopifnot(length(out.idx) == 1)
      out[out.idx, new.col] <- out[out.idx, response] -
        k.dat[i, "var1.pred"]
    }
  }

  return(out)
}
