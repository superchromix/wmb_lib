;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_hmmviterbi.pro
;
;   This function calculates the most probable state path for a sequence.
;   
;   STATES = wmb_hmmviterbi(SEQ,TRANSITIONS,EMISSIONS) given a sequence, 
;   SEQ, calculates the most likely path through the Hidden Markov Model
;   specified by transition probability matrix, TRANSITIONS, and emission
;   probability matrix, EMISSIONS. 
;   
;   TRANSITIONS(I,J) is the probability of transition from state I to state J. 
;   
;   EMISSIONS(K,L) is the probability that symbol L is emitted from state K. 
;
;   The SYMBOLS keyword allows you to specify the symbols that are emitted. 
;   SYMBOLS can be a numeric array or a string array of the names of the 
;   symbols.  The default symbols are integers 0 through N-1, where N is the 
;   number of possible emissions.
;
;   The STATENAMES keyword allows you to specify the names of the states. 
;   STATENAMES can be a numeric array or a string array of the names of the 
;   states. The default statenames are 0 through M-1, where M is the number 
;   of states.
;
;   This function always starts the model in state 1 and then makes a
;   transition to the first step using the probabilities in the first row
;   of the transition matrix. So in the example given below, the first
;   element of the output states will be 1 with probability 0.95 and 2 with
;   probability .05.
;
;   Examples:
;
;       tr = [0.95,0.05;
;             0.10,0.90];
;           
;       e = [1/6,  1/6,  1/6,  1/6,  1/6,  1/6;
;            1/10, 1/10, 1/10, 1/10, 1/10, 1/2;];
;
;       seq = wmb_hmmgenerate(100,tr,e);
;       estimatedStates = wmb_hmmviterbi(seq,tr,e);
;
;       seq = wmb_hmmgenerate(100,tr,e,STATENAMES=['fair','loaded'])
;       estimatesStates = wmb_hmmviterbi(seq,tr,e,STATENAMES=['fair','loaded'])
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_hmmviterbi, seq, $
                         tr, $
                         em, $
                         logp = logp, $
                         symbols = symbols, $
                         statenames = statenames

    compile_opt idl2, strictarrsubs

    ; check the dimensions of the input variables
    tr_dims = size(tr, /DIMENSIONS)
    numstates = tr_dims[0]
    if tr_dims[0] ne tr_dims[1] then message, 'Invalid transition matrix'

    ; number of rows of em must be same as number of states
    em_dims = size(em, /DIMENSIONS)
    if em_dims[0] ne numstates then message, 'Input size mismatch'
    n_emissions = em_dims[1]
     
    custom_statenames = 0

    if N_elements(symbols) ne 0 then begin

        n_symbol_names = N_elements(symbols)
        if n_symbol_names ne n_emissions then message, 'Invalid symbols'
        result = wmb_ismember(seq,symbols,locs=locs)
        
        ; note that we are over-writing the original seq variable here
        seq = locs
        
        if min(seq) lt 0 then message, 'Missing symbol'

    endif

    if N_elements(statenames) ne 0 then begin
        
        n_state_names = N_elements(statenames)
        if n_state_names ne numstates then message, 'Bad state names'
        custom_statenames = 1
        
    endif

    ; work in log space to avoid numerical issues

    L = N_elements(seq)
    
    if min(seq) lt 0 OR $
       min(seq eq round(seq)) eq 0 OR $
       max(seq) gt (n_emissions-1) OR $
       L eq 0 then begin
        
        message, 'Bad sequence'
        
    endif
    
    currentstate = lonarr(L)
    
    logTR = alog(tr)
    logEM = alog(em)
    
    ; allocate space
    
    pTR = lonarr(numstates, L)
    
    ; assumption is that model is in state 1 at step 0
    
    v = dblarr(numstates, /NOZERO)
    v[*] = - !VALUES.F_INFINITY
    v[0] = 0
    vOld = v
    
    ; loop through the model
    
    for cnta = 0, L-1 do begin
        
        for cur_state = 0, numstates-1 do begin
            
            ; for each state we calculate 
            ; v(state) = e(state,seq(count))* max_k(vOld(:)*tr(k,state))
            
            bestVal = - !VALUES.F_INFINITY
            bestPTR = 0
            
            ; use a loop to avoid lots of calls to max
            
            for inner = 0, numStates-1 do begin
                
                val = vOld[inner] + logTR[inner,cur_state]
                
                if val gt bestVal then begin
                    
                    bestVal = val
                    bestPTR = inner
                    
                endif
                
            endfor
            
            ; save the best transition information for later backtracking
            
            pTR[cur_state,cnta] = bestPTR
            
            ; update v
            
            v[cur_state] = logEM[cur_state,seq[cnta]] + bestVal
            
        endfor

        vOld = v

    endfor
    
    ; decide which of the final states is most probable
    
    logP = max(v, finalState)
    
    ; Now back trace through the model
    
    currentState[L] = finalState

    for cnta = L-2, 0, -1 do begin
        
        currentState[cnta] = pTR[currentState[cnta+1],cnta+1]
        
        if currentState[cnta] eq 0 then message, 'Zero transition probability'
        
    endfor
    
    if custom_statenames eq 1 then begin
        
        currentState = statenames[currentState]
        
    endif

    return, currentState
    
end

