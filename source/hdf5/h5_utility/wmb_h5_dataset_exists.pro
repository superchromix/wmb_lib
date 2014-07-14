

; wmb_h5_dataset_exists
;
; Purpose: Verify that a given dataset exists within an HDF5 file.
; 
; Note that datasetname is case sensitive.
;
; Returns 1 if the group or dataset exists.


function wmb_h5_dataset_exists, filename, datasetname

    compile_opt idl2, strictarrsubs

    if filename eq '' then message, 'Error: Invalid file name'
    if datasetname eq '' then message, 'Error: Invalid dataset name'

    ; check if filename exists, is writable, and is a valid hdf5 file

    fn_exists = (file_info(filename)).exists

    if fn_exists then fn_is_hdf5 = h5f_is_hdf5(filename) $
                 else fn_is_hdf5 = 0

    if ~fn_exists or ~fn_is_hdf5 then begin
        
        message, 'Error: invalid HDF5 file'
        return, 0
        
    endif
    
    ; filename is ok - open it and parse its contents

    h5_list, filename, filter=datasetname, output=h5listoutput

    ; check that the datasetname is unique
    
    output_ndims = size(h5listoutput,/n_dimensions)
    outputdims = size(h5listoutput,/dimensions)
    
    ; if nothing was found matching the filter, then a 1D array will be
    ; returned
    
    if output_ndims ne 2 then return, 0
    
    ; if matches to the filter are found, a 2D string array is returned
    
    n_found = outputdims[1] - 1
    if n_found ne 1 then return, 0
    
    ; check that the object type is a dataset
    
    if h5listoutput[0,1] ne 'dataset' then return, 0
    
    ; check that the dataset name matches exactly
    
    if h5listoutput[1,1] ne datasetname then return, 0
    
    ; all test have passed - the dataset exists
    
    return, 1
    
end