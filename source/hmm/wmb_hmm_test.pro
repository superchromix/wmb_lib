
pro wmb_hmm_test

    tr = [[0.95,0.1], [0.05,0.9]]
    
    e = [[1./6, 1./10], [1./6, 1./10], [1./6, 1./10], $
         [1./6, 1./10], [1./6, 1./10], [1./6, 1./2]]

    seq = wmb_hmmgenerate(100,tr,e,states=realstates)
    
    ; tic
    
    estimatedStates = wmb_hmmviterbi(seq,tr,e)
    
    ; toc
    
    p = PLOT(realstates, "g4-", YTITLE='State', $
        DIM=[450,400], MARGIN=0.2, YRANGE=[-0.2,1.2], AXIS_STYLE=1)
    
    
    p1 = PLOT(estimatedStates, "r2-", /overplot)
          
    p2 = PLOT(seq, /current, "k+2", YRANGE=[-1,6], AXIS_STYLE=4)

    p2.position = p.position

    yaxis = AXIS('Y', LOCATION='right', TITLE='Sequence', TARGET=p2)    
    
    
;    sym = ['one','two','three','four','five','six']
;    seq = wmb_hmmgenerate(100,tr,e,SYMBOLS=sym,STATES=realstates2)
;    estimatedStates2 = wmb_hmmviterbi(seq,tr,e,SYMBOLS=sym)
;    
;    pp = PLOT(realstates2, "g4-", YTITLE='State', $
;              DIM=[450,400], MARGIN=0.2, YRANGE=[-0.2,1.2], AXIS_STYLE=1)
;              
;    pp1 = PLOT(estimatedStates2, "r2-", /overplot)
    
end
