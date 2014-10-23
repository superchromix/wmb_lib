;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_meshgrid
;
;   Transforms the domain specified by vectors x_domain and y_domain into 
;   arrays X_out and Y_out that can be used for the evaluation of functions 
;   of two variables and 3-D surface plots.  The rows of the output array X_out
;   are copies of the vector x_domain and the columns of the output array 
;   Y_out are copies of the vector y_domain.
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_meshgrid, x_domain, y_domain, X_out, Y_out

    len_x = N_ELEMENTS(x_domain)
    len_y = N_ELEMENTS(y_domain)
    
    X_out = x_domain#REPLICATE(1,len_y)
    Y_out = y_domain##REPLICATE(1,len_x)

end