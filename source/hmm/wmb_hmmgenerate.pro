;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_hmmgenerate.pro
;
;   This function generates a sequence of symbols, given a transition
;   matrix and an emission matrix.  It is adapted from the Matlab 
;   function "hmmgenerate".
;   
;   SEQ = wmb_hmmgenerate(LEN,TRANSITIONS,EMISSIONS,STATES=STATES) 
;   generates a sequence of emission symbols, SEQ, and a random sequence of 
;   states, STATES, of length LEN from a Markov Model specified by transition
;   probability matrix, TRANSITIONS, and EMISSION probability matrix,
;   EMISSIONS. TRANSITIONS[I,J] is the probability of transition from state
;   I to state J. EMISSIONS[K,L] is the probability that symbol L is
;   emitted from state K. 
;   
;   TRANSITIONS[I,J] is the probability of transition from state I to state J. 
;   
;   EMISSIONS[K,L] is the probability that symbol L is emitted from state K. 
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
;   This function always starts the model in state 0 and then makes a
;   transition to the first step using the probabilities in the first row
;   of the transition matrix. So in the example given below, the first
;   element of the output states will be 0 with probability 0.95 and 1 with
;   probability .05.
;
;   Examples:
;
;       tr = [[0.95,0.10], [0.05,0.90]]
;           
;       e = [[1./6, 1./10], [1./6, 1./10], [1./6, 1./10], $
;            [1./6, 1./10], [1./6, 1./10], [1./6, 1./2]]
;
;
;       seq = wmb_hmmgenerate(100,tr,e)
;
;       seq = wmb_hmmgenerate(100,tr,e, $
;                  SYMBOLS=['one','two','three','four','five','six'],
;                  STATENAMES=[['fair'],['loaded']])
;
;   Note that this program depends on REPMAT.PRO from the Coyote IDL library.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_hmmgenerate, len, $
                          tr, $
                          em, $
                          states = states, $
                          symbols = symbols, $
                          statenames = statenames

    compile_opt idl2, strictarrsubs

    seq = lonarr(len)
    states = lonarr(len)
    
    ; check the dimensions of the input variables
    tr_dims = size(tr, /DIMENSIONS)
    n_states = tr_dims[0]
    if tr_dims[0] ne tr_dims[1] then message, 'Invalid transition matrix'

    ; number of columns of em must be same as number of states
    em_dims = size(em, /DIMENSIONS)
    if em_dims[0] ne n_states then message, 'Input size mismatch'
    n_emissions = em_dims[1]

    custom_symbols = 0
    custom_statenames = 0

    if N_elements(symbols) ne 0 then begin

        n_symbol_names = N_elements(symbols)
        if n_symbol_names ne n_emissions then message, 'Invalid symbols'
        custom_symbols = 1

    endif

    if N_elements(statenames) ne 0 then begin

        n_state_names = N_elements(statenames)
        if n_state_names ne n_states then message, 'Bad state names'
        custom_statenames = 1

    endif


    ; create two random sequences, one for state changes, one for emission

    seeda = systime(/SECONDS)
    statechange = randomu(seeda, len) 
    randvals = randomu(seeda, len) 

    ; calculate cumulative probabilities

    trc = total(tr,2,/CUMULATIVE)
    ec = total(em,2,/CUMULATIVE)

    ; normalize these just in case they don't sum to 1
    
    trc = trc / repmat(trc[*,-1],1,n_states)
    ec = ec / repmat(ec[*,-1],1,n_emissions)
    

    ; assume that we start in state 0
    
    currentstate = 0

    ; main loop
    
    for cnta = 0, len-1 do begin
        
        ; calculate state transition
        
        stateval = statechange[cnta]
        tmp_state = 0
        
        for innerstate = n_states-2,0,-1 do begin
            
            if stateval gt trc[currentstate,innerstate] then begin
                
                ; set the state and exit the for loop
                tmp_state = innerstate + 1
                break
                
            endif
           
        endfor
        
        ; calculate emission
        
        val = randvals[cnta]
        
        emit = 0
        
        for inner = n_emissions-2,0,-1 do begin
            
            if val gt ec[tmp_state,inner] then begin
                
                emit = inner + 1
                break
                
            endif
            
        endfor
        
        ; add values and states to output
        
        seq[cnta] = emit
        states[cnta] = tmp_state
        currentstate = tmp_state
        
    endfor

    ; deal with names/symbols

    if custom_symbols eq 1 then seq = symbols[seq]
    if custom_statenames eq 1 then states = statenames[states]

    return, seq
    
end

