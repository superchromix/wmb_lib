12/06/2012  Removed ROBUST_LINEFIT, ROBUST_POLY_FIT, ROBUST_SIGMA, HISTOGAUSS,
       AUTOHIST, BIWEIGHT_MEAN, MEDSMOOTH(), RESISTANT_MEAN, ROB_CHECKFIT
       because newer versions are in the main Astro library

07/30/2012  PERMUTE moved to the main Astro Library


                                ROBLIB                           3/25/94
                                              Updated 2/21/95
                                                      5/31/95
                                                     11/02/95
     
     H.T. Freudenreich, HSTX
     freudenreich@tonga.gsfc.nasa.gov


     Glitches got you down?  Do you get get sick with envy when you see
     examples in "Numerical Recipes" or other books of pristine data with
     errors that are normally distributed, and then look at your own
     terminal and see something that looks like it's having a bad hair day?

     Try ROBLIB, the library of IDL routines for people who work with real
     data. It'll handle much of your smoothing, fitting and general analysis
     chores and it laughs at glitches and other outliers. It requires IDL
     3.5 or later.

     The core of ROBLIB:
     MED               Calculate median (Prior to V5.0, MEDIAN worked on only 
                       odd numbers)
     ROBUST_SIGMA      Robust analog of the standard deviation
     ROBUST_LINEFIT    Robust fit of Y vs X (or bisector of Y vs X and X vs Y)
     ROBUST_REGRESS    Robust multiple linear regression (calls REGRESS)     
     ROBUST_POLY_FIT   Robust polynomial fit (calls POLYFITW)     
     PLANEFIT          Fit to Z = a + bX + cY. 
     ROBUST_PLANEFIT   Robust fit to same (calls PLANEFIT)
     QUARTICFIT        Fit to Z = a + bX + cY + dXY + eX^2 + fY^2
     ROBUST_QUARTICFIT Robust fit to same (calls QUARTICFIT)
     ROB_MAPFIT        Robust fit to 2D (map form) data. User may specify
                       pixels to ignore in calculating the surface.
     LOWESS            LOWESS method of smoothing 1D data. Also returns "noise".
                       "local, weighted" iterative polynomial fits.
     LOESS             Same for 2D (pixelized) data. 
     CHAINSAW          A "lower envelope" determination of a 2D background.
                       Fits a plane to minima within the neighborhood of each
                       pixel. Good for clear-cutting point sources.
     BIWEIGHT_MEAN     Iterative biweighted determination of mean, std. dev.

     Also useful are:
     AUTOHIST          Draw a histogram using automatic bin-sizing.  Bug in
                       histogram shading fixed July 1999 
     HISTOGAUSS        Outlier-resistant autoscaled histogram drawing
     HALFAGAUSS        Like HISTOGAUSS. Breaks distribution into a Gaussian+
                       "tail" distribution. For distributions that are basically
                       Gaussian on one side of the mode.
     MEDSMOOTH         Running-median smoother of 1D data. Also smooths points
                       near the ends of the vector, unlike MEDIAN.
     RPLOT             PLOT with robust setting of the Y range. Outliers are
                       clipped; the clipping region is marked on the graph.
                       
     ROBUST_BOXCAR     Robust boxcar averages
     ROBUST_BINDATA    Robust 1D histogram. User specifies bin-widths.
     BOOT_BINDATA      Same as above, but uses bootstrap method to determine
                       uncertainties.
     ROBUST_BIN2D      Robust 2D histogram (map)

     ROBUST_CORR       Robust correlation coefficient for Y vs X
     POINT_REMOVER     Iterative replacement of high signal/noise pixels from 
                       a map. The S/N calculation is made for the neighborhood
                       of each pixel. A slow but safe method.
     MAPFITW           Fit to 2D data with user-supplied weights per pixel
     RESISTANT_MEAN    A trimmed-median approach to a robust mean. Throws 
                       out values based on the median absolute deviation
                       from the median. 

     BBOOTSTRAP        Bootstrap evaluation of a user-supplied function.
                       The function must return a scalar. 
     PERMUTE           Randomly shuffles the elements of a vector.   (A much
                       faster algorithm for PERMUTE was introduced by Joe 
		       Harrington in March 2006. 
     BOOT_POLYFIT      Bootstrap robust polynomial fit. Returns N_SAMPLE sets 
                       of coefficients. Allows user to find confidence limits.
     FITXYERRS         Robust linear fit to data with errors in both X and Y.
                       X and Y treated symmetrically. Bootstrap method is used
                       to determine the uncertainties in slope and intercept.
                       An error in the computation of the Y intercept was 
                       corrected in Nov. 1995
     R_ERODE, R_DILATE Like ERODE and DILATE, but operate on floating-point
                       data and can be made to ignore missing or flagged data.
