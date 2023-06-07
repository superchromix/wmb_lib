pro splinecoeff_test

    compile_opt idl2, strictarrsubs

    seeda = systime(/SECONDS)

    n_points = 20

    noise_sd = 1.0    
    delta_x = 8.0
    osc_ampl = 10.0
    osc_period = 155.0
    osc_offset = 20.0

    xdat = findgen(n_points) * delta_x
    ydat = sin((xdat/osc_period)*2.0*!pi)*osc_ampl + osc_offset

    gnoise = randomu(seeda, n_points, /NORMAL)*noise_sd
    
    ydat = ydat + gnoise

    ;result = daxview_plot_xy_data(xdat,ydat,LINESTYLE=6, SYMBOL=obj_new('IDLgrSymbol'))

    spl_lambda = 1000.0
    spl_weights = ydat
    spl_weights[*] = 1.0
    
    spl_coeffs = splineCOEFF_calculate(xdat, ydat, spl_weights, LAMBDA = spl_lambda)

    npoints_x_new = 10
    new_xmin = xdat[0]
    new_xmax = xdat[-1]
    new_deltax = (new_xmax-new_xmin)/(npoints_x_new-1)
    new_x = (lindgen(npoints_x_new) * new_deltax) < new_xmax

    ydat_spline = splineCOEFF_render(new_x,x_output,xdat,spl_coeffs)

    tmpx = [xdat,x_output]
    tmpy = [ydat,ydat_spline]
    plot_x_dimsize = [N_elements(xdat), N_elements(x_output)]
    ch_start_indices = [0, N_elements(xdat)]
    nchannels = 2
    nplots = 1
    linestyle = [6,0]
    symbol = [obj_new('IDLgrSymbol',6),obj_new('IDLgrSymbol',0)]

    pd = obj_new('dv_PlotdataStack3D', Indata = tmpy, $
                                       X_values = tmpx, $
                                       Nplots = nplots, $
                                       Nchannels = nchannels, $
                                       Plot_x_dimsize = plot_x_dimsize)

    result = daxview_show_data(pd, $
                               linestyle = linestyle, $
                               symbol = symbol)

end