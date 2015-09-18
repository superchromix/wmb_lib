;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_DataTable object class
;
;   This file defines the wmb_DataTable object class.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc



;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Overload array indexing for the wmb_DataTable object
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_DataTable::_overloadBracketsLeftSide, objref,  $
                                              value,   $
                                              isRange, $
                                              sub1,    $
                                              sub2,    $
                                              sub3,    $
                                              sub4,    $
                                              sub5,    $
                                              sub6,    $
                                              sub7,    $
                                              sub8

    compile_opt idl2, strictarrsubs

    if N_elements(sub1) eq 0 then begin
        message, 'Error: no array subscript specified'
    endif

    ; determine the number of indices/ranges specified
    n_inputs = N_elements(isrange)

    if n_inputs ne 1 then begin
        message, 'Error: invalid array subscript'
    endif

    chk_range = isRange[0]

    if chk_range eq 0 and N_elements(sub1) gt 1 then index_is_array = 1 $
                                                else index_is_array = 0

    ; test validity of indices and ranges
    chkpass = 1
    chkdim = self.dt_nrecords

    if chk_range eq 1 then begin
        if ~ wmb_Rangevalid(sub1, chkdim, positive_range=psub1) then chkpass=0
    endif else begin
        if ~ wmb_Indexvalid(sub1, chkdim, positive_index=psub1) then chkpass=0
    endelse

    if chkpass eq 0 then begin
        message, 'Error: array subscript out of range'
    endif

    if chk_range eq 1 then begin
        
        startrecord = psub1[0]
        endrecord = psub1[1]
        stride = psub1[2]
        
    endif else begin
        
        if index_is_array eq 0 then index = psub1[0] $
                               else index = psub1
        
    endelse

    ; check that value is a valid record or array of records
    value_n_dims = size(value, /N_DIMENSIONS)
    if value_n_dims ne 1 then message, 'Invalid variable dimension'
    
    value_dtype = size(value, /TYPE)
    if value_dtype ne 8 then message, 'Invalid variable datatype'
    
    ; if the record definition is already initialized, then compare it to
    ; the input data. 

    indata_sample = value[0]

    if self.dt_flag_record_def_init then begin
        
        recdef = *(self.dt_record_def_ptr)
           
        structs_match = wmb_compare_struct(indata_sample, $
                                           recdef, $
                                           /COMPARE_FIELD_NAMES, $
                                           /IGNORE_FIELD_VALUES)

        if ~structs_match then begin
            message, 'Error: indata structure does not match table structure'
        endif
        
    endif 

    ; get the size of the input data
    value_n_elts = N_elements(value)
    
    ; test if the number of elements in value matches the subscript
    
    input_scalar = value_n_elts eq 1
    
    if chk_range eq 1 then begin
        
        ; the subscript is a range - check that the number of elements 
        ; in value matches the size of the range
        
        range_size = ceil( (abs(startrecord-endrecord)+1) $
                           / float(abs(stride)), /L64)
    
        input_matches_range = range_size eq value_n_elts

    endif


    ; is the data stored in memory or on disk?
    
    if self.dt_flag_vtable eq 1 or self.dt_autosave_activated eq 1 then begin

        ; flush the write buffer
        self -> Flush_writebuffer

        ; open the file
        loc_id = self -> Vtable_Open(dset_name=dset_name)
        
        ; write the data to disk
        
        if chk_range eq 1 then begin
                                       
            wmb_h5tb_write_records_range, loc_id, $
                                          dset_name, $
                                          startrecord, $
                                          endrecord, $
                                          stride, $
                                          value
            
        endif else begin
            
            wmb_h5tb_write_records_index, loc_id, $
                                          dset_name, $
                                          index, $
                                          value
            
        endelse


        ; close the file
        self -> Vtable_Close

    endif else begin
        
        ; write the data to memory
        
        datavector = self.dt_datavector
        
        if chk_range eq 1 then begin
        
            if stride eq 1 then begin
                
                if input_matches_range then begin
                    
                    datavector[startrecord] = value
                    
                endif else if input_scalar then begin
                    
                    datavector[startrecord:endrecord] = value
                    
                endif else message, 'Array subscript does not match ' + $
                                    'size of input data'
                
            endif else begin
                
                datavector[startrecord:endrecord:stride] = value
                
            endelse
            
        endif else begin
            
            datavector[index] = value
            
        endelse
        
    endelse

end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Overload array indexing for the wmb_DataTable object
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_DataTable::_overloadBracketsRightSide, isRange, sub1, $
    sub2, sub3, sub4, sub5, sub6, sub7, sub8

    compile_opt idl2, strictarrsubs

    if N_elements(sub1) eq 0 then begin
        message, 'Error: no array subscript specified'
        return, 0
    endif

    if self.dt_flag_table_empty then begin
        message, 'Error: table empty'
        return, 0
    endif

    ; determine the number of indices/ranges specified
    n_inputs = N_elements(isrange)

    if n_inputs ne 1 then begin
        message, 'Error: invalid array subscript'
        return, 0
    endif

    chk_range = isRange[0]

    if chk_range eq 0 and N_elements(sub1) gt 1 then index_is_array = 1 $
                                                else index_is_array = 0

    ; test validity of indices and ranges
    chkpass = 1
    chkdim = self.dt_nrecords

    if chk_range eq 1 then begin
        if ~ wmb_Rangevalid(sub1, chkdim, positive_range=psub1) then chkpass=0
    endif else begin
        if ~ wmb_Indexvalid(sub1, chkdim, positive_index=psub1) then chkpass=0
    endelse


    if chkpass eq 0 then begin
        message, 'Error: array subscript out of range'
        return, 0
    endif


    if chk_range eq 1 then begin
        
        startrecord = psub1[0]
        endrecord = psub1[1]
        stride = psub1[2]
        
        chk_return_scalar = 0
        
    endif else begin
        
        if index_is_array eq 0 then index = psub1[0] $
                               else index = psub1
        
        chk_return_scalar = ~index_is_array
        
    endelse


    ; is the data stored in memory or on disk?
    
    if self.dt_flag_vtable eq 1 or self.dt_autosave_activated eq 1 then begin

        ; flush the write buffer
        self -> Flush_writebuffer

        ; open the file
        loc_id = self -> Vtable_Open(dset_name=dset_name)
        
        ; get the data from disk
        
        if chk_range eq 1 then begin
            
            wmb_h5tb_read_records_range, loc_id, $
                                         dset_name, $
                                         startrecord, $
                                         endrecord, $
                                         stride, $
                                         databuffer
            
        endif else begin
            
            wmb_h5tb_read_records_index, loc_id, $
                                         dset_name, $
                                         index, $
                                         databuffer
            
        endelse


        ; close the file
        self -> Vtable_Close

    endif else begin
        
        ; get the data from memory
        
        datavector = self.dt_datavector
        
        if chk_range eq 1 then begin
        
            databuffer = datavector[startrecord:endrecord:stride]
        
        endif else begin
            
            databuffer = datavector[index]
            
        endelse
        
    endelse

    return, databuffer

end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Overload the size function for the wmb_DataTable object
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_DataTable::_overloadSize

    compile_opt idl2, strictarrsubs

    result = [self.dt_nrecords]
    
    return, result

end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Append method
;   
;   Returns 1 if successful
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_DataTable::Append, indata, no_copy=no_copy

    compile_opt idl2, strictarrsubs

    if N_elements(indata) eq 0 then message, 'Error: no input data'

    if N_elements(no_copy) eq 0 then no_copy = 0

    indata_is_struct = size(indata,/type) eq 8
    
    if ~indata_is_struct then begin
        message, 'Error: Indata must be a structure type'
        return, 0
    endif
        
    if size(indata,/n_dimensions) gt 1 then begin
        message, 'Error: Input data must be scalar or 1-dimensional'
        return, 0
    endif

    recorddef_init = self.dt_flag_record_def_init

    ; if the record definition is already initialized, then compare it to
    ; the input data.  if not, create a new record definition based on the 
    ; input data.

    indata_sample = indata[0]

    if recorddef_init then begin
        
        recdef = *(self.dt_record_def_ptr)
           
        structs_match = wmb_compare_struct(indata_sample, $
                                           recdef, $
                                           /COMPARE_FIELD_NAMES, $
                                           /IGNORE_FIELD_VALUES)

        if ~structs_match then begin
            message, 'Error: indata structure does not match table structure'
            return, 0
        endif
        
    endif else begin
        
        recdef = wmb_h5tb_data_to_record_definition(indata)
        
        self.dt_nfields = n_tags(recdef)
        self.dt_record_def_ptr = ptr_new(recdef)
        self.dt_flag_record_def_init = 1
        
        recdef_size_bytes = wmb_sizeofstruct(recdef)
        
        autosave_thresh_mbytes = self.dt_autosave_thresh_mbytes
        autosave_thresh_nrecs = ( (autosave_thresh_mbytes*(1024LL^2)) $
                                  / recdef_size_bytes ) + 1LL

        self.dt_size_of_record_def = recdef_size_bytes
        self.dt_autosave_thresh_nrecs = autosave_thresh_nrecs
        
    endelse


    ; handle the NO_COPY keyword

    if no_copy eq 0 then begin

        tmp_indata = indata

    endif else begin

        tmp_indata = temporary(indata)

    endelse


    ; is the table stored in memory or on disk?
    
    if self.dt_flag_vtable eq 1 or self.dt_autosave_activated eq 1 then begin
        
        ; if the table is on disk, then the table is not empty
        ; (you cannot save an empty table)
        
        if self.dt_flag_table_empty then begin
            message, 'Error: empty table stored on disk'
            return, 0
        endif
        
        ; does the write buffer exist?

        if ~obj_valid(self.dt_write_buffer) then begin
            
            ; initialize the write buffer
            
            recdef = *self.dt_record_def_ptr
            buflen = self.dt_write_buffer_length
            
            writebuffer = obj_new('wmb_vector', $
                                  datatype=8, $
                                  structure_type_def=recdef, $
                                  initial_capacity = buflen+1, $           
                                  double_capacity_if_full = 1)
            
            self.dt_write_buffer = writebuffer
            
        endif
        
        writebuffer = self.dt_write_buffer
        writebuffer_len = self.dt_write_buffer_length
        
        buf_nrecs = writebuffer.size
        buf_space = writebuffer_len - buf_nrecs
        
        ; how many records are we writing?
        indata_length = N_elements(tmp_indata)
        
        
        ; is there space in the write buffer?
        
        if indata_length lt buf_space then begin
            
            writebuffer.Append, tmp_indata, /NO_COPY
            self.dt_nrecords = self.dt_nrecords + indata_length
            
        endif else begin
        
            ; flush the write buffer
            
            self -> Flush_writebuffer
        
            ; write the new records to disk
        
            loc_id = self -> Vtable_Open(dset_name=dset_name)
        
            wmb_h5tb_append_records, loc_id, $
                                     dset_name, $
                                     indata_length, $
                                     tmp_indata
        
            self.dt_nrecords = self.dt_nrecords + indata_length

            ; release the tmp_indata variable
            tmp_indata = 0
        
            ; close the file
            self -> Vtable_Close
            
        endelse

    endif else begin
        
        tmp_nrecords = size(tmp_indata, /dimensions)
        
        ; is the table empty?
        
        if self.dt_flag_table_empty then begin

            ; create the datavector object
            
            recdef = *self.dt_record_def_ptr
            
            datavector = obj_new('wmb_vector', $
                                 datatype=8, $
                                 structure_type_def=recdef, $
                                 initial_capacity = 10000, $           
                                 double_capacity_if_full = 1)
                                   
            datavector.Append, tmp_indata, /NO_COPY
            
            self.dt_datavector = datavector
            self.dt_nrecords = tmp_nrecords
            self.dt_flag_table_empty = 0
            
        endif else begin
        
            ; add the new records to memory
            
            datavector = self.dt_datavector
            datavector.Append, tmp_indata, /NO_COPY
            
            self.dt_nrecords = datavector.size

        endelse
        
    endelse

    self -> Check_autosave

    return, 1

end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Append_table method
;
;   Returns 1 if successful
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_DataTable::Append_table, input_table

    compile_opt idl2, strictarrsubs

    if isa(input_table, 'wmb_datatable') eq 0 then begin
        
        message, 'Input table must be a WMB_DATATABLE object'
        return, 0
    
    endif

    recorddef_init = self.dt_flag_record_def_init

    ; if the record definition is already initialized, then compare it to
    ; the input data.  if not, create a new record definition based on the
    ; input data.

    if recorddef_init eq 1 then begin

        recdef_a = *self.dt_record_def_ptr
        recdef_b = input_table.recorddef
        
        if wmb_compare_struct(recdef_a, recdef_b, /COMPARE_FIELD_NAMES, $
                              /IGNORE_FIELD_VALUES) eq 0 then begin
             
            message, 'Unmatched record definitions'                   
            return, 0
                       
        endif
    
    endif else begin
        
        recdef = input_table.recorddef
        
        self.dt_nfields = n_tags(recdef)        
        self.dt_record_def_ptr = ptr_new(recdef)
        self.dt_flag_record_def_init = 1

        recdef_size_bytes = wmb_sizeofstruct(recdef)

        autosave_thresh_mbytes = self.dt_autosave_thresh_mbytes
        autosave_thresh_nrecs = ( (autosave_thresh_mbytes*(1024LL^2)) $
            / recdef_size_bytes ) + 1LL

        self.dt_size_of_record_def = recdef_size_bytes
        self.dt_autosave_thresh_nrecs = autosave_thresh_nrecs
        
    endelse
    
    
    ; copy the input table, chunk by chunk

    chunksize = 50000
    
    table_len = input_table.nrecords
    
    if table_len gt 0 then begin
    
        n_chunks = ceil(float(table_len)/chunksize)
        
        for i = 0, n_chunks-1 do begin
            
            srec = i * chunksize
            erec = (((i+1)*chunksize) - 1) < (table_len - 1)
            
            tmp_dat = input_table[srec:erec]
            
            result = self.Append(tmp_dat, /NO_COPY)
            
        endfor
        
    endif

    return, 1

end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Check_autosave method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_DataTable::Check_autosave

    compile_opt idl2, strictarrsubs
    
    chk_as_thresh = self.dt_nrecords ge self.dt_autosave_thresh_nrecs
    chk_vtable = self.dt_flag_vtable
    
    ; do we need to auto-save the table to disk?
    
    if (self.dt_autosave_enabled eq 1) and $
       (self.dt_autosave_activated eq 0) and $
       (chk_as_thresh eq 1) and $
       (chk_vtable eq 0) then begin
        
        title = 'autosave'
        dset_name = 'autosave'
        grp_name = 'autosave'
        chunksize = 10000
        compressflag = 0
        
        ; get a temporary file name
        tmp_fn = filepath(cmunique_id() + '.tmp',/TMP)
        
        ; we now have a valid filename, title, group name, and dataset name
        tmp_recdef = *(self.dt_record_def_ptr)
        tmp_data = (self.dt_datavector)[*]
        tmp_nrecords = self.dt_nrecords

        ; destroy the datavector object
        obj_destroy, self.dt_datavector

        ; check if filename exists
        fn_exists = (file_info(tmp_fn)).exists
        if fn_exists eq 1 then message, 'Error: temporary file exists'
        
        ; create the file
        fid = h5f_create(tmp_fn)
        h5f_close, fid
        
        ; create the group
        rslt = wmb_h5_create_group(tmp_fn, grp_name)
        if rslt ne 1 then message, 'Error opening group'        
        
        ; open the file
        fid = h5f_open(tmp_fn, /WRITE)

        ; open the group
        loc_id = h5g_open(fid, grp_name)

        ; write the table
        wmb_h5tb_make_table, title, $
                             loc_id, $
                             dset_name, $
                             tmp_nrecords, $
                             tmp_recdef, $
                             chunksize, $
                             compressflag, $
                             databuffer = tmp_data


        ; we are done!  populate the self fields
        self.dt_autosave_activated = 1
        self.dt_autosave_vtable_open = 1
        self.dt_autosave_filename = tmp_fn
        self.dt_autosave_fid = fid
        self.dt_autosave_loc_id = loc_id

        ; close the hdf file
        self -> Vtable_Close
        
    endif
    
end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Consolidate_table method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_DataTable::Consolidate_table

    compile_opt idl2, strictarrsubs
    
    self -> Consolidate_Memory
    self -> Flush_writebuffer
    
end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Consolidate_memory method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_DataTable::Consolidate_memory

    compile_opt idl2, strictarrsubs
    
    if self.dt_flag_vtable eq 0 and $
       self.dt_autosave_activated eq 0 and $
       obj_valid(self.dt_datavector) then begin
        
        datavector = self.dt_datavector
        
        datavector.Consolidate
        
    endif 
    
end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Flush_writebuffer method
;
;   Flush the contents of the write buffer to disk
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_DataTable::Flush_writebuffer

    compile_opt idl2, strictarrsubs
    
    if (self.dt_flag_vtable eq 1 or self.dt_autosave_activated eq 1) $
       and obj_valid(self.dt_write_buffer) then begin
        
        writebuffer = self.dt_write_buffer
        writebuffer_len = self.dt_write_buffer_length
        
        loc_id = self -> Vtable_Open(dset_name=dset_name)

        buf_nrecs = writebuffer.size        
        
        ; write the contents of the write buffer to disk

        buf_data = writebuffer[*]
        
        wmb_h5tb_append_records, loc_id, $
                                 dset_name, $
                                 buf_nrecs, $
                                 buf_data
        
        ; close the file
        self -> Vtable_Close
        
        ; empty the write buffer
        obj_destroy, writebuffer
        
    endif
    
end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Read_column method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_DataTable::Read_column, col_name, $
                                     start_index = start_index, $
                                     n_records = n_records

    compile_opt idl2, strictarrsubs
    
    table_nrecs = self.dt_nrecords
    
    if N_elements(start_index) eq 0 then start_index = 0
    if N_elements(n_records) eq 0 then n_records = table_nrecs
    
    if (start_index + n_records) gt table_nrecs then $
        message, 'Invalid record range'
    
    ; which column are we working with?
    
    recdef = *(self.dt_record_def_ptr)
    stored_colnames = strupcase(tag_names(recdef))
    input_colname = strupcase(col_name)
    col_ind = where(stored_colnames eq input_colname, tmpcnt)
    if tmpcnt ne 1 then message, 'Invalid column name'

    databuffer = []
    
    if self.dt_flag_table_empty eq 0 then begin

        if self.dt_flag_vtable eq 1 or $
           self.dt_autosave_activated eq 1 then begin
            
            ; flush the write buffer
            self -> Flush_writebuffer
            
            loc_id = self.Vtable_Open(dset_name=dset_name)
            
            wmb_h5tb_read_fields_index, loc_id, $
                                        dset_name, $
                                        col_ind, $
                                        start_index, $
                                        n_records, $
                                        databuffer
            
            ; convert the array of (single field) structures into a 
            ; normal array

            databuffer = temporary(databuffer.(0))
            
            ; close the file
            self.Vtable_Close
            
        endif else begin
            
            dvector = self.dt_datavector
            
            ; create an array of the correct type
            
            firstrec = dvector[0]
            tmp_element = firstrec.(col_ind)
            tmp_dtype = size(tmp_element, /TYPE)
            databuffer = make_array(n_records, type=tmp_dtype, /NOZERO)
            
            chunksize = 100000 < n_records
            
            n_chunks = ceil(float(n_records) / chunksize)
            
            last_rec = (start_index + n_records) - 1
            
            for i = 0, n_chunks-1 do begin
                
                srec = (i*chunksize) + start_index
                erec = ((((i+1)*chunksize) - 1) + start_index) < last_rec
                
                tmpdata = dvector[srec:erec]
                databuffer[i*chunksize] = tmpdata.(col_ind)
                
            endfor
    
        endelse
        
    endif
    
    return, databuffer
    
end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Write_column method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_DataTable::Write_column, col_name, start_index, databuffer

    compile_opt idl2, strictarrsubs
    
    table_nrecs = self.dt_nrecords
    n_records = N_elements(databuffer)    
    
    if (start_index + n_records) gt table_nrecs then $
        message, 'Invalid record range'
    
    ; which column are we working with?
    
    recdef = *(self.dt_record_def_ptr)
    stored_colnames = strupcase(tag_names(recdef))
    input_colname = strupcase(col_name)
    col_ind = where(stored_colnames eq input_colname, tmpcnt)
    if tmpcnt ne 1 then message, 'Invalid column name'

    if self.dt_flag_vtable eq 1 or self.dt_autosave_activated eq 1 then begin
        
        ; flush the write buffer
        self -> Flush_writebuffer
        
        ; convert databuffer from a normal array to an array of 
        ; single field structures
        
        tmpstruct = create_struct(col_name, databuffer[0])
        tmpbuffer = replicate(tmpstruct, n_records)
        tmpbuffer.(0) = temporary(databuffer)
        databuffer = temporary(tmpbuffer)
        
        loc_id = self.Vtable_Open(dset_name=dset_name)
        
        chunksize = 100000 < n_records
        n_chunks = ceil(float(n_records) / chunksize)
        
        last_read = (n_records-1)
        last_write = (start_index + n_records) - 1
        
        for i = 0, n_chunks-1 do begin
            
            srec_read = (i*chunksize)
            erec_read = (((i+1)*chunksize) - 1) < last_read
            
            srec_write = (i*chunksize) + start_index
            erec_write = ((((i+1)*chunksize) - 1) + start_index) < last_write
            
            nrecs = (erec_write - srec_write) + 1
            
            input_buffer = databuffer[srec_read:erec_read]
            
            wmb_h5tb_write_fields_index, loc_id, $
                                         dset_name, $
                                         col_ind, $
                                         srec_write, $
                                         nrecs, $
                                         input_buffer
            
            
        endfor
        
        ; close the file
        self.Vtable_Close
        
    endif else begin
        
        dvector = self.dt_datavector
        
        chunksize = 100000 < n_records
        n_chunks = ceil(float(n_records) / chunksize)
        
        last_read = (n_records-1)
        last_write = (start_index + n_records) - 1
        
        for i = 0, n_chunks-1 do begin
            
            srec_read = (i*chunksize)
            erec_read = (((i+1)*chunksize) - 1) < last_read
            
            srec_write = (i*chunksize) + start_index
            erec_write = ((((i+1)*chunksize) - 1) + start_index) < last_write
            
            nrecs = (erec_write - srec_write) + 1
            
            input_buffer = databuffer[srec_read:erec_read]
            
            tmpdata = dvector[srec_write:erec_write]
            tmpdata.(col_ind) = input_buffer
            
            dvector[srec_write:erec_write] = tmpdata
            
        endfor

    endelse
    
end



;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Reorder_table method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_DataTable::Reorder_table, reorder_index

    compile_opt idl2, strictarrsubs
    

    ; open the virtual table and create a temporary file if necessary
    
    if self.dt_flag_vtable eq 1 or self.dt_autosave_activated eq 1 then begin

        ; flush the write buffer
        self -> Flush_writebuffer

        ; open the virtual table
        
        loc_id = self.Vtable_Open(dset_name=dset_name)

        recdef = *(self.dt_record_def_ptr)
        
        ; create a temporary file
        
        tmpfile = filepath(cmunique_id() + '.tmp', /TMP)

        ; check if the temporary file already exists

        fn_exists = (file_info(tmpfile)).exists
        
        if fn_exists then message, 'Error: temporary file already exists'
        
        ; create the file
        
        tmp_fid = h5f_create(tmpfile)
        h5f_close, tmp_fid
        
        ; create the group
        
        full_group_name = 'temporary_group'
        rslt = wmb_h5_create_group(tmpfile, full_group_name)
        if rslt ne 1 then message, 'Error opening group'    
        
        ; open the file
        tmp_fid = h5f_open(tmpfile, /WRITE)

        ; open the group
        tmp_loc_id = h5g_open(tmp_fid, full_group_name)

        ; create the table
                
        tmp_title = 'temporary_table'
        tmp_dset_name = 'temporary_table'
        table_chunksize = 10000
        compressflag = 0                
            
        wmb_h5tb_make_table, tmp_title, $
                             tmp_loc_id, $
                             tmp_dset_name, $
                             0, $
                             recdef, $
                             table_chunksize, $
                             compressflag

        n_records = self.dt_nrecords
        chunksize = 100000 < n_records
        n_chunks = ceil(float(n_records) / chunksize)
        last_write = (n_records-1)

        ; reorder the table into temporary storage
        
        for i = 0, n_chunks-1 do begin
            
            srec = (i*chunksize)
            erec = (((i+1)*chunksize) - 1) < last_write
            
            nrecs = (erec - srec) + 1
            
            tmp_reorder_index = reorder_index[srec:erec]
            
            ; read a chunk
            
            wmb_h5tb_read_records_index, loc_id, $
                                         dset_name, $
                                         tmp_reorder_index, $
                                         databuffer
        
            ; write a chunk to the temporary file
            
            wmb_h5tb_append_records, tmp_loc_id, $
                                     tmp_dset_name, $
                                     nrecs, $
                                     databuffer
            
        endfor
    
        ; copy the reordered data back to the original location
    
        for i = 0, n_chunks-1 do begin
            
            srec = (i*chunksize)
            erec = (((i+1)*chunksize) - 1) < last_write
            
            nrecs = (erec - srec) + 1
            
            tmp_reorder_index = reorder_index[srec:erec]
            
            ; read a chunk
            
            wmb_h5tb_read_records, tmp_loc_id, $
                                   tmp_dset_name, $
                                   srec, $
                                   nrecs, $
                                   databuffer
        
            ; write a chunk to the original table
            
            wmb_h5tb_write_records, loc_id, $
                                    dset_name, $
                                    srec, $
                                    nrecs, $
                                    databuffer
            
        endfor
        
        ; close the temporary file and delete it
            
        h5g_close, tmp_loc_id
        h5f_close, tmp_fid
        file_delete, tmpfile
        
        ; close the virtual table
        self.Vtable_Close

    endif else begin
        
        dvector = self.dt_datavector
        
        ; perform the entire operation in memory
        
        dvector[0] = dvector[reorder_index]
        
    endelse
    
end



;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Sort_single_index method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_DataTable::Sort_single_index, col_name, descending=descending

    compile_opt idl2, strictarrsubs
    
    if N_elements(descending) ne 1 then descending = 0
    
    table_nrecs = self.dt_nrecords
    
    ; read the column which will act as the sort index
    
    tmpdata = self.Read_column(col_name)
    
    sort_index = sort(tmpdata)
    
    if descending eq 1 then sort_index = reverse(sort_index, /OVERWRITE)
    
    self -> Reorder_table, sort_index

end



;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Sort_double_index method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_DataTable::Sort_double_index, col_name_1, $
                                      col_name_2, $
                                      descending=descending

    compile_opt idl2, strictarrsubs
    
    if N_elements(descending) ne 1 then descending = 0
    
    table_nrecs = self.dt_nrecords
    
    ; read the column which will act as the primary sort index
    
    tmpdata1 = self.Read_column(col_name_1)
    
    ; read the column which will act as the secondary sort index
    
    tmpdata2 = self.Read_column(col_name_2)
    
    sort_index = wmb_sort_two_columns(tmpdata1, tmpdata2)
    
    if descending eq 1 then sort_index = reverse(sort_index, /OVERWRITE)
    
    self -> Reorder_table, sort_index

end



;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Select method
;
;   Select a set of elements from the table, based on filter 
;   criteria.
;
;   filter_columns: a list of column names which will be used
;                   for selection
;                   
;   filter_types: 0: select values greater than or equal to
;                 1: select values less than or equal to
;                 2: select values within [min,max] range
;                 3: select values equal to
;                 4: select values not equal to
;                 
;   filter_values: A list of filter values.  For range filters,
;                  the value is a two-element array of [min,max].
;
;   Returns an array of indices to the table.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_DataTable::Select, filter_columns, $
                                filter_types, $
                                filter_values

    compile_opt idl2, strictarrsubs

    ; which columns are we working with?
    
    recdef = *(self.dt_record_def_ptr)
       
    colnames = strupcase(tag_names(recdef))
    
    col_index_list = list()
    
    foreach tmpstr, filter_columns, tmpind do begin
        
        tmpstr = strupcase(tmpstr)
        
        tmpa = where(colnames eq tmpstr, tmpcnt)
        
        if tmpcnt eq 0 then message, 'Column not found'
        
        col_index_list.Add, tmpa
        
    endforeach

    n_filters = N_elements(col_index_list)

    ; are we going to process the table in chunks or in 
    ; one pass?
    
    chunksize = 500000
    
    n_recs = self.dt_nrecords
    
    nchunks = ceil(float(n_recs)/chunksize)
    
    select_results = []
    
    for i = 0, nchunks-1 do begin
        
        si = i*chunksize
        ei = (((i+1)*chunksize)-1) < (n_recs-1)
        tmp_nr = (ei-si) + 1
        
        tmp_pass_markers = bytarr(tmp_nr,n_filters)
        
        tmpdat = self[si:ei]
        
        foreach colindex, col_index_list, tmpi do begin
            
            ftype = filter_types[tmpi]
            fval = filter_values[tmpi]
            
            case ftype of
                
                0: begin
                    
                    tmp_rslt = where(tmpdat.(colindex) ge fval, tmpcnt)
                    if tmpcnt gt 0 then tmp_pass_markers[tmp_rslt,tmpi] = 1
                    
                end
                
                1: begin
                    
                    tmp_rslt = where(tmpdat.(colindex) le fval, tmpcnt)
                    if tmpcnt gt 0 then tmp_pass_markers[tmp_rslt,tmpi] = 1
                    
                end
                
                2: begin
                    
                    tmpmin = fval[0]
                    tmpmax = fval[1]
                    tmp_rslt = where(tmpdat.(colindex) ge tmpmin and $
                                     tmpdat.(colindex) le tmpmax, tmpcnt)
                    if tmpcnt gt 0 then tmp_pass_markers[tmp_rslt,tmpi] = 1
                    
                end
                
                3: begin

                    tmp_rslt = where(tmpdat.(colindex) eq fval, tmpcnt)
                    if tmpcnt gt 0 then tmp_pass_markers[tmp_rslt,tmpi] = 1
                    
                end
                
                4: begin

                    tmp_rslt = where(tmpdat.(colindex) ne fval, tmpcnt)
                    if tmpcnt gt 0 then tmp_pass_markers[tmp_rslt,tmpi] = 1
                    
                end
                
            endcase
            
        endforeach
        
        overall_pass = where(total(tmp_pass_markers,1) eq n_filters, tmpcnt)
        
        if tmpcnt gt 0 then select_results = [select_results, overall_pass]
        
    endfor

    return, select_results

end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Load method
;
;   Load a table from an existing file.  Works only for empty
;   tables.
;
;   Returns 1 if the load operation was successful.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_DataTable::Load, filename, full_group_name, dset_name

    compile_opt idl2, strictarrsubs

    if N_elements(filename) eq 0 then begin
        message, 'Error: invalid filename'
        return, 0
    endif

    if N_elements(full_group_name) eq 0 then begin
        message, 'Error: invalid group name'
        return, 0
    endif

    if N_elements(dset_name) eq 0 then begin
        message, 'Error: invalid dataset name'
        return, 0
    endif

    if ~self.dt_flag_table_empty then begin
        message, 'Error: table not empty'
        return, 0
    endif
        
    ; check if filename exists, is writable, and is a valid hdf5 file

    if ~wmb_h5_file_test(filename, /WRITE) then begin
        
        message, 'Error: invalid HDF5 file'
        return, 0
        
    endif

    ; verify that the dataset exists
    
    chk_dset_exists = wmb_h5_dataset_exists(filename,full_group_name,dset_name)

    if ~chk_dset_exists then begin
        message, 'Error: HDF5 dataset not found'
        return, 0
    endif

    ; this appears to be a valid HDF5 file and the specfied dataset exists
    
    ; open the file
    
    fid = h5f_open(filename, /WRITE)
    
    loc_id = h5g_open(fid, full_group_name)

    ; get information about the table size
    
    wmb_h5tb_get_table_info, loc_id, $
                             dset_name, $
                             nfields, $
                             nrecords, $
                             TITLE=dset_title_attr, $
                             CLASS=dset_class_attr

    if strupcase(dset_class_attr) ne 'TABLE' then begin
        message, 'Error: HDF5 dataset is not a table type'
        return, 0
    endif

    ; get the record data structure
    
    wmb_h5tb_get_field_info, loc_id, dset_name, record_definition


    ; we are done!  populate the self fields
    
    self.dt_title = dset_title_attr
    self.dt_dataset_name = dset_name
    self.dt_full_group_name = full_group_name
    self.dt_record_def_ptr = ptr_new(record_definition)
    self.dt_flag_record_def_init = 1
    self.dt_nfields = nfields
    self.dt_nrecords = nrecords
    self.dt_flag_vtable = 1
    self.dt_vtable_open = 1
    self.dt_vtable_filename = filename
    self.dt_vtable_fid = fid
    self.dt_vtable_loc_id = loc_id
    self.dt_flag_table_empty = 0

    ; close the file
    self -> Vtable_Close

    return, 1

end



;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Save method
;
;   Save a table from memory into an HDF5 file.  From this point
;   on, the datatable will be accessed as a virtual table.
;
;   Returns 1 if the save operation was successful.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_DataTable::Save, filename, $
                              full_group_name, $
                              dset_name, $
                              Title = title, $
                              Chunksize = chunksize, $
                              CompressFlag = compressflag


    compile_opt idl2, strictarrsubs

    if N_elements(filename) eq 0 then begin
        message, 'Error: invalid filename'
        return, 0
    endif

    if N_elements(full_group_name) eq 0 then begin
        message, 'Invalid group name'
        return, 0
    endif
    
    if N_elements(dset_name) eq 0 then begin
        message, 'Invalid dataset name'
        return, 0
    endif
    
    if N_elements(title) eq 0 then title = self.dt_title
    if N_elements(chunksize) eq 0 then chunksize = 10000
    if N_elements(compressflag) eq 0 then compressflag = 0

    if self.dt_flag_table_empty then begin
        message, 'Error: empty table'
        return, 0
    endif

    if self.dt_flag_vtable eq 1 then begin
        message, 'Error: table already written to disk'
        return, 0
    endif

    if size(title,/type) ne 7 or $
       size(dset_name,/type) ne 7 or $
       size(full_group_name,/type) ne 7 then begin
        
        message, 'Error: Title, Group and Dataset names must be scalar strings'
        return, 0
        
    endif

    if size(title,/n_dimensions) ne 0 or $
       size(dset_name,/n_dimensions) ne 0 or $
       size(full_group_name,/n_dimensions) ne 0 then begin
        
        message, 'Error: Title, Group and Dataset names must be scalar strings'
        return, 0
        
    endif


    ; has an autosave file already been created?  if so, simply write the 
    ; data to the new location
    
    if self.dt_autosave_activated eq 1 then begin
        
        tmp_data = self[*]
        
        file_delete, self.dt_autosave_filename

        self.dt_autosave_activated = 0

    endif else begin

        tmp_data = (self.dt_datavector)[*]

        ; destroy the datavector object
        obj_destroy, self.dt_datavector

    endelse


    ; check if filename exists and is writable

    fn_exists = (file_info(filename)).exists

    if fn_exists then chk_hdf5 = wmb_h5_file_test(filename, /WRITE) $
                 else chk_hdf5 = 0

    if fn_exists and ~chk_hdf5 then begin
        message, 'Error: invalid HDF5 file'
        return, 0   
    endif
    
    
    ; if the file exists, check whether the group or dataset exist

    if fn_exists then begin

        chk_group_exists = 0
        chk_dset_exists = 0

        chk_group_exists = wmb_h5_group_exists(filename, full_group_name)
        
        if chk_group_exists then begin
            
            chk_dset_exists = wmb_h5_dataset_exists(filename, $
                                                    full_group_name, $
                                                    dset_name)
                                                    
            if chk_dset_exists then begin
                message, 'Error: dataset exists'
                return, 0
            endif
            
        endif else begin
            
            ; create the group
            
            if ~wmb_h5_create_group(filename, full_group_name) then begin
                message, 'Error: HDF5 group could not be created'
                return, 0
            endif
            
        endelse

    endif


    ; we now have a valid filename, title, group name, and dataset name

    tmp_recdef = *(self.dt_record_def_ptr)
    tmp_nrecords = self.dt_nrecords


    ; ensure that the file exists

    if ~fn_exists then begin

        fid = h5f_create(filename)
        h5f_close, fid
        
        ; create the group
        
        rslt = wmb_h5_create_group(filename, full_group_name)
        if rslt ne 1 then message, 'Error opening group'        
        
    endif


    ; open the file
    
    fid = h5f_open(filename, /WRITE)


    ; open the group
    
    loc_id = h5g_open(fid, full_group_name)


    ; write the table

    wmb_h5tb_make_table, title, $
                         loc_id, $
                         dset_name, $
                         tmp_nrecords, $
                         tmp_recdef, $
                         chunksize, $
                         compressflag, $
                         databuffer = tmp_data


    ; we are done!  populate the self fields

    self.dt_title = title
    self.dt_dataset_name = dset_name
    self.dt_full_group_name = full_group_name
    
    self.dt_flag_vtable = 1
    self.dt_vtable_open = 1
    self.dt_vtable_filename = filename
    self.dt_vtable_fid = fid
    self.dt_vtable_loc_id = loc_id


    ; close the hdf file
    self -> Vtable_Close
        

    return, 1

end



;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Erase method
;
;   Removes all of the records from memory.  If the table is 
;   saved to disk, the dataset within the HDF5 file is deleted.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_DataTable::Erase, delete_file_if_empty = delete_file_if_empty

    compile_opt idl2, strictarrsubs

    if N_elements(delete_file_if_empty) eq 0 then delete_file_if_empty = 0

    if self.dt_flag_vtable eq 1 then begin

        ; the data is stored on disk
        
        ; open the data table
        
        loc_id = self.Vtable_Open(dset_name=dset_name)
        
        ; unlink the dataset
        
        h5g_unlink, loc_id, dset_name
        
        ; close the table
         
        self.Vtable_Close
        
        ; check if we are deleting the file
        
        if delete_file_if_empty eq 1 then begin
            
            fn = self.dt_vtable_filename
            
            wmb_h5_list, fn, filter='dataset', output=file_contents
            
            tmp = where(file_contents[0,*] eq 'dataset', n_ds)
            
            if n_ds eq 0 then begin
                
                ; there are no datasets remaining in the file, so it
                ; will be deleted
                
                file_delete, fn
                
            endif
            
        endif
        
        ; erase the write buffer
        obj_destroy, self.dt_write_buffer

    endif else if self.dt_autosave_activated eq 1 then begin
        
        ; the data is stored on disk (autosaved)
        
        self.Vtable_Close
        
        file_delete, self.dt_autosave_filename
        
        ; erase the write buffer
        obj_destroy, self.dt_write_buffer
        
    endif else begin
        
        ; delete the data vector from memory
        obj_destroy, self.dt_datavector

    endelse


    ; reset the internal data
    
    self.dt_nrecords         = 0
    self.dt_datavector       = obj_new()
    
    self.dt_flag_vtable      = 0
    self.dt_vtable_open      = 0
    self.dt_vtable_filename = ''
    
    self.dt_autosave_activated = 0
    self.dt_autosave_vtable_open = 0
    self.dt_autosave_filename = ''

    self.dt_flag_table_empty = 1

end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Vtable_Open method
;
;   Open the HDF5 file for reading/writing
;
;   Returns the loc_id for the group in which the dataset is found
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_DataTable::Vtable_Open, dset_name = dset_name

    compile_opt idl2, strictarrsubs

    chk_autosave = self.dt_autosave_activated eq 1
    chk_vtable = self.dt_flag_vtable eq 1
    
    if chk_autosave eq 1 and chk_vtable eq 1 then begin
        message, 'Autosave and virtual table out of sync'
        return, -1
    endif

    if self.dt_autosave_activated eq 1 then begin
        
        loc_id = self.dt_autosave_loc_id
        dset_name = 'autosave'        
        
        if self.dt_autosave_vtable_open eq 0 then begin
        
            ; open the autosave file
            
            filename = self.dt_autosave_filename
            groupname = 'autosave'
            
            fid = h5f_open(filename,/WRITE)
            loc_id = h5g_open(fid, groupname)
        
            self.dt_autosave_fid = fid
            self.dt_autosave_loc_id = loc_id
            self.dt_autosave_vtable_open = 1
        
        endif
        
    endif
    
    if self.dt_flag_vtable eq 1 then begin
        
        loc_id = self.dt_vtable_loc_id
        dset_name = self.dt_dataset_name
        
        if self.dt_vtable_open eq 0 then begin
                
            ; open the virtual table file
                
            filename = self.dt_vtable_filename
            groupname = self.dt_full_group_name
            
            fid = h5f_open(filename,/WRITE)
            loc_id = h5g_open(fid, groupname)
        
            self.dt_vtable_fid = fid
            self.dt_vtable_loc_id = loc_id
            self.dt_vtable_open = 1
        
        endif
        
    endif

    return, loc_id

end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Vtable_Close method
;
;   Close the HDF5 file
;
;   Returns 1 if the save operation was successful.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_DataTable::Vtable_Close

    compile_opt idl2, strictarrsubs

    if self.dt_autosave_vtable_open eq 1 then begin
            
        fid = self.dt_autosave_fid
        loc_id = self.dt_autosave_loc_id
        
        h5g_close, loc_id
        h5f_close, fid
    
        self.dt_autosave_vtable_open = 0
    
    endif
        
    if self.dt_vtable_open eq 1 then begin
            
        fid = self.dt_vtable_fid
        loc_id = self.dt_vtable_loc_id
        
        h5g_close, loc_id
        h5f_close, fid
    
        self.dt_vtable_open = 0
    
    endif

end


;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the GetProperty method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_DataTable::GetProperty,  recorddef = recorddef, $
                                 nfields = nfields, $
                                 nrecords = nrecords, $
                                 title = title, $
                                 datasetname = datasetname, $
                                 groupname = groupname, $
                                 vtable_flag = vtable_flag, $
                                 filename = filename, $
                                 table_empty = table_empty, $
                                 _Ref_Extra=extra

    compile_opt idl2, strictarrsubs


    if Arg_present(recorddef) ne 0 then recorddef=(*self.dt_record_def_ptr)
    if Arg_present(nfields) ne 0 then nfields=self.dt_nfields
    if Arg_present(nrecords) ne 0 then nrecords=self.dt_nrecords
    if Arg_present(title) ne 0 then title=self.dt_title
    if Arg_present(datasetname) ne 0 then datasetname=self.dt_dataset_name
    if Arg_present(groupname) ne 0 then groupname=self.dt_full_group_name
    if Arg_present(vtable_flag) ne 0 then vtable_flag=self.dt_flag_vtable
    if Arg_present(filename) ne 0 then filename=self.dt_vtable_filename
    if Arg_present(table_empty) ne 0 then table_empty=self.dt_flag_table_empty
    
    ; pass extra keywords

    
end



;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Init method
;
;   If the data, or a pointer to the data, is passed directly
;   to the DataStack object upon creation, then the other
;   fields such as nfields and nrecords are filled in based on
;   the data.
;
;   If the NO_COPY keyword is set to 1, the input data variable 
;   will be undefined after the object is created.
;
;   A RecordDef structure may be provided to define the record 
;   structure of the table.  This is a structure variable whose tag
;   names are the field names of the table.  The datatype of each 
;   field of the RecordDef structure sets the datatype of the table
;   columns.  For string type fields, the corresponding field of 
;   the record definition must be filled with a number of characters
;   equal to the maximum string length of the field.
;   
;   If a record definition is not provided, it is set automatically
;   the first time data is added to the table.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_DataTable::Init, Indata=indata, $
                              No_copy=no_copy, $
                              RecordDef=recorddef, $
                              Title = title, $
                              Autosave_enable = autosave_enable, $
                              Autosave_thresh_mbytes = autosave_thresh_mbytes, $
                              Write_buffer_length = write_buffer_length
                              

    compile_opt idl2, strictarrsubs


    if N_elements(no_copy) eq 0 then no_copy = 0

    if N_elements(title) eq 0 then title = 'Table'

    if N_elements(write_buffer_length) eq 0 then write_buffer_length = 50000
    
    if N_elements(autosave_enable) eq 0 then autosave_enable = 0
    
    ; default autosave threshold is 256MB
    if N_elements(autosave_thresh_mbytes) eq 0 then autosave_thresh_mbytes=256

    indata_present = N_elements(indata) ne 0
    recorddef_present = N_elements(recorddef) ne 0
    
    
    ; check the record definition
        
    if recorddef_present then begin
        
        if size(recorddef,/n_dimensions) gt 1 then begin
            message, 'Error: Record definition must be scalar'
            return, 0
        endif
        
        if size(recorddef,/dimensions) gt 1 then begin
            message, 'Error: Record definition must be scalar'
            return, 0
        endif

        if size(recorddef,/type) ne 8 then begin
            message, 'Error: invalid record definition'
            return, 0
        endif
        
        if n_tags(recorddef) eq 0 then begin
            message, 'Error: invalid record definition'
            return, 0
        endif

        recdef_size_bytes = wmb_sizeofstruct(recorddef)
        
        autosave_thresh_nrecs = ( (autosave_thresh_mbytes*(1024LL^2)) $
                                  / recdef_size_bytes ) + 1LL

    endif
    
    
    ;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
    ;
    ;   populate the self fields
    ;

    self.dt_title                  = title
    self.dt_dataset_name           = 'Dataset'
    self.dt_full_group_name        = '/'
    self.dt_record_def_ptr         = ptr_new()
    self.dt_flag_record_def_init   = 0
     
    self.dt_nfields                = 0
    self.dt_nrecords               = 0
    
    self.dt_datavector             = obj_new()
    self.dt_write_buffer           = obj_new()
    self.dt_write_buffer_length    = write_buffer_length
  
    self.dt_autosave_thresh_mbytes = autosave_thresh_mbytes
    self.dt_autosave_enabled       = autosave_enable
    self.dt_autosave_activated     = 0
    self.dt_autosave_filename      = ''
    self.dt_autosave_fid           = 0
    self.dt_autosave_loc_id        = 0
    self.dt_autosave_vtable_open   = 0
  
    self.dt_flag_vtable            = 0L
    self.dt_vtable_open            = 0
    self.dt_vtable_filename        = ''
    self.dt_vtable_fid             = 0L
    self.dt_vtable_loc_id          = 0L
    
    self.dt_flag_table_empty       = 1

    
    if recorddef_present then begin
        
        self.dt_record_def_ptr = ptr_new(recorddef)
        self.dt_flag_record_def_init = 1
        self.dt_nfields = n_tags(recorddef)
        
        self.dt_size_of_record_def = recdef_size_bytes
        self.dt_autosave_thresh_nrecs = autosave_thresh_nrecs
        
    endif


    if indata_present then inittype = 'inputvar' $
                      else inittype = 'empty_table'


    case inittype of

        'inputvar': begin

            if ~self->Append(indata, no_copy=no_copy) then return, 0

        end


        'empty_table': begin
            

            
        end
        
    endcase


    ;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
    ;
    ;   finished initializing wmb_DataTable object
    ;

    return, 1

end




;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Cleanup method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_DataTable::Cleanup

    compile_opt idl2, strictarrsubs

    self -> Flush_writebuffer

    self -> Vtable_Close

    ptr_free, self.dt_record_def_ptr
    
    if obj_valid(self.dt_datavector) then obj_destroy, self.dt_datavector
    
    if obj_valid(self.dt_write_buffer) then obj_destroy, self.dt_write_buffer

    if self.dt_autosave_activated eq 1 then $
        file_delete, self.dt_autosave_filename

end




;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_DataTable__define.pro
;
;   wmb_DataTable is an object class encapsulating the 
;   functionality of the H5TB Table interface for HDF5.
;   
;   A wmb_DataTable object stores data in a 1D array of structure
;   variables.  Each table must have attributes such as a "title" 
;   and a "dataset name".  The data may be stored on disk or in
;   memory - this is transparent to the user.  When stored on 
;   disk, the data is stored in the HDF5 table format.
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_DataTable__define

    compile_opt idl2, strictarrsubs


    struct = { wmb_DataTable,                              $
        INHERITS IDL_Object,                               $
                                                           $
        dt_title                    : '',                  $
        dt_dataset_name             : '',                  $
        dt_full_group_name          : '',                  $            
                                                           $
        dt_record_def_ptr           : ptr_new(),           $
        dt_flag_record_def_init     : fix(0),              $
        dt_size_of_record_def       : 0L,                  $
                                                           $
        dt_nfields                  : long64(0),           $
        dt_nrecords                 : long64(0),           $
                                                           $                                                  
        dt_datavector               : obj_new(),           $
        dt_write_buffer             : obj_new(),           $
        dt_write_buffer_length      : 0L,                  $
                                                           $
        dt_autosave_thresh_mbytes   : 0LL,                 $
        dt_autosave_thresh_nrecs    : 0LL,                 $
        dt_autosave_enabled         : fix(0),              $
        dt_autosave_activated       : fix(0),              $
        dt_autosave_filename        : '',                  $
        dt_autosave_fid             : long(0),             $
        dt_autosave_loc_id          : long(0),             $
        dt_autosave_vtable_open     : fix(0),              $
                                                           $
        dt_flag_vtable              : fix(0),              $
        dt_vtable_filename          : '',                  $
        dt_vtable_open              : fix(0),              $
        dt_vtable_fid               : long(0),             $
        dt_vtable_loc_id            : long(0),             $
                                                           $
        dt_flag_table_empty         : fix(0)               }

end

