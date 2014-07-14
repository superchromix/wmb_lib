

; wmb_h5_dataset_exists
;
; Purpose: Verify that a given dataset exists within an HDF5 file.
; 
; Note that dataset_full_name is case sensitive.
;
; Returns 1 if the dataset exists.


function wmb_h5_dataset_exists, filename, dataset_full_name

    compile_opt idl2, strictarrsubs

    if filename eq '' then message, 'Error: Invalid file name'
    if dataset_full_name eq '' then message, 'Error: Invalid dataset name'

    ; check if filename exists, is writable, and is a valid hdf5 file

    fn_exists = (file_info(filename)).exists

    if fn_exists then fn_is_hdf5 = h5f_is_hdf5(filename) $
                 else fn_is_hdf5 = 0

    if ~fn_exists or ~fn_is_hdf5 then begin
        
        message, 'Error: invalid HDF5 file'
        return, 0
        
    endif
    

    ; strip off the leading '/' in dataset_full_name if it is present

    if strmid(dataset_full_name,0,1) eq '/' then begin
        
        dataset_full_name = strmid(dataset_full_name,1)

    endif


    ; open the HDF5 file and parse the contents

    h5_list, filename, filter=dataset_full_name, output=h5listoutput

    output_ndims = size(h5listoutput,/n_dimensions)
    outputdims = size(h5listoutput,/dimensions)
    
    ; if nothing was found matching the filter, then a 1D array will be
    ; returned
    
    if output_ndims ne 2 then return, 0
    
    ; if matches to the filter are found, a 2D string array is returned
    
    n_found = outputdims[1] - 1
    if n_found eq 0 then return, 0
    
    dataset_found = 0
    
    for i = 0, n_found-1 do begin
        
        tmptype = h5listoutput[0,i+1]
        tmpname = h5listoutput[1,i+1]
        
        if strmid(tmpname,0,1) eq '/' then tmpname = strmid(tmpname,1)
        
        if tmptype eq 'dataset' and tmpname eq dataset_full_name then begin
            
            dataset_found = 1
            
        endif
        
    endfor
    
    return, dataset_found
    
end