;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_meshgrid_nd
;
;   Returns a list of grid arrays, with one element for each dimension
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_meshgrid_nd, dim_vectors

    compile_opt idl2, strictarrsubs

    ; Number of dimensions
    ndims = N_elements(dim_vectors)

    ; Create an empty list to hold the meshgrid arrays
    meshgrid = list()

    ; Loop through each dimension
    for i = 0, ndims - 1 do begin
        
        ; Initial grid: just the vector along its dimension
        grid = dim_vectors[i]
        
        ; We need to reshape this grid so it varies along the ith dimension
        ; and has size 1 along all other dimensions.
        dimensions = REPLICATE(1, ndims)
        dimensions[i] = N_ELEMENTS(grid)
        
        ; Start by creating a basic grid array for the current dimension
        grid = reform(grid, dimensions)
        
        ; Replicate across other dimensions
        for j = 0, ndims - 1 do begin
            
            if i ne j then begin
            
                ; The size to replicate is the number of elements in the 
                ; jth dimension vector
                replication_dims = size(grid, /DIMENSIONS)
                replication_dims[j] = N_elements(dim_vectors[j])
                
                grid = reform(rebin(grid, replication_dims), replication_dims)
                
            endif
        endfor

        ; Add the final grid array for this dimension to the list
        meshgrid.Add, grid
        
    endfor

    ; Return the list of meshgrid arrays
    return, meshgrid

end


