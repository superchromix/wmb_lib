;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Helper methods for testing valid indices and ranges
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

function wmb_DataTable::Rangevalid, range, positive_range=positive_range

    compile_opt idl2, strictarrsubs
        
    chkdim = self.dt_nrecords
    
    rangestart = range[0]
    if rangestart lt 0 then rangestart = rangestart + chkdim
    rangeend = range[1]
    if rangeend lt 0 then rangeend = rangeend + chkdim
    rangestride = range[2]

    minrange = 0L
    maxrange = chkdim - 1L
    
    maxstride = abs(rangeend-rangestart) > 1
    minstride = -maxstride

    if (rangestart lt minrange) or (rangestart gt maxrange) then return, 0
    if (rangeend lt minrange) or (rangeend gt maxrange) then return, 0
    
    if (rangestride eq 0) then return, 0
    if (rangestride lt minstride) or (rangestride gt maxstride) then return, 0
    
    if (rangestart lt rangeend) and (rangestride lt 0) then return, 0
    if (rangestart gt rangeend) and (rangestride gt 0) then return, 0

    positive_range = [rangestart,rangeend,rangestride]

    return, 1

end


function wmb_DataTable::Indexvalid, index, positive_index = positive_index

    compile_opt idl2, strictarrsubs

    chkdim = self.dt_nrecords
    
    test_index = index
    if test_index lt 0 then test_index = test_index + chkdim
    
    minrange = 0L
    maxrange = chkdim - 1L
    
    if (test_index lt minrange) or (test_index gt maxrange) then return, 0
    
    positive_index = test_index
    
    return, 1
    
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

    ; test validity of indices and ranges
    chkpass = 1

    if chk_range eq 1 then begin
        if ~ self->Rangevalid(sub1, positive_range=psub1) then chkpass = 0
    endif else begin
        if ~ self->Indexvalid(sub1, positive_index=psub1) then chkpass = 0
    endelse

    if chkpass eq 0 then begin
        message, 'Error: array subscript out of range'
        return, 0
    endif

    if chk_range eq 1 then begin
        
        startrecord = psub1[0]
        endrecord = psub1[1]
        stride = psub1[2]
        
    endif else begin
        
        startrecord = psub1[0]
        endrecord = psub1[0]
        stride = 1
        
    endelse


    ; is the data stored in memory or on disk?
    
    if self.dt_flag_vtable then begin

        ; open the file
        loc_id = self -> Vtable_Open()
        dset_name = self.dt_dataset_name
        
        ; get the data from disk
        
        tmp_disk_start = startrecord < endrecord
        tmp_disk_end = startrecord > endrecord
        tmp_disk_nrecords = tmp_disk_end - tmp_disk_start + 1
        
        wmb_h5tb_read_records, loc_id, $
                               dset_name, $
                               tmp_disk_start, $
                               tmp_disk_nrecords, $
                               databuffer

        ; close the file
        self -> Vtable_Close

        if stride ne 1 then begin
            
            if stride gt 0 then begin
                
                ; stride is positive so endrecord > startrecord
                tmp_data = databuffer[0:tmp_disk_nrecords-1:stride]
                
            endif else begin
                
                ; stride is negative so endrecord < startrecord
                tmp_data = databuffer[tmp_disk_nrecords-1:0:stride]
                
            endelse

            databuffer = temporary(tmp_data)
            
        endif

    endif else begin
        
        ; get the data from memory
        
        if chk_range eq 1 then begin
        
            databuffer = (*self.dt_dataptr)[startrecord:endrecord:stride]
        
        endif else begin
            
            databuffer = (*self.dt_dataptr)[startrecord]
            
        endelse
        
    endelse

    return, databuffer

end

;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the Append method
;   
;   Returns 1 if successful
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_DataTable::Append, indata, nocopy=nocopy

    compile_opt idl2, strictarrsubs

    if N_elements(indata) eq 0 then message, 'Error: no input data'

    if N_elements(nocopy) eq 0 then nocopy = 0

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
        
    endelse


    ; handle the NOCOPY keyword

    if nocopy eq 0 then begin

        tmp_indata = indata

    endif else begin

        tmp_indata = temporary(indata)

    endelse


    ; is the table stored in memory or on disk?
    
    if self.dt_flag_vtable then begin
        
        ; if the table is on disk, then the table is not empty
        ; (you cannot save an empty table)
        
        if self.dt_flag_table_empty then begin
            message, 'Error: empty table stored on disk'
            return, 0
        endif
        
        ; write the new records to disk
        
        loc_id = self -> Vtable_Open()
        dset_name = self.dt_dataset_name
        nrecords = N_elements(tmp_indata)
        
        wmb_h5tb_append_records, loc_id, $
                                 dset_name, $
                                 nrecords, $
                                 tmp_indata
        
        self.dt_nrecords = self.dt_nrecords + nrecords

        ; release the tmp_indata variable
        tmp_indata = 0
        
        ; close the file
        self -> Vtable_Close

    endif else begin
        
        tmp_nrecords = size(tmp_indata, /dimensions)
        
        ; is the table empty?
        
        if self.dt_flag_table_empty then begin

            self.dt_dataptr = ptr_new(tmp_indata, /NO_COPY)
            self.dt_nrecords = tmp_nrecords
            self.dt_flag_table_empty = 0
            
        endif else begin
        
            ; add the new records to memory
            
            tmpdat = temporary(*(self.dt_dataptr))
            ptr_free, self.dt_dataptr
            newdat = [temporary(tmpdat),temporary(tmp_indata)]
            
            self.dt_nrecords = N_elements(newdat)

            ; note that newdat is undefined after this call
            self.dt_dataptr = ptr_new(newdat, /NO_COPY)

        endelse
        
    endelse

    return, 1

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

    if N_elements(full_group_name) eq 0 then $
        full_group_name = self.dt_full_group_name

    if N_elements(dset_name) eq 0 then dset_name = self.dt_dataset_name

    if N_elements(title) eq 0 then title = self.dt_title
    if N_elements(chunksize) eq 0 then chunksize = 1000
    if N_elements(compressflag) eq 0 then compressflag = 0

    if self.dt_flag_table_empty then begin
        message, 'Error: empty table'
        return, 0
    endif

    if self.dt_flag_vtable then begin
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
    tmp_data = temporary(*(self.dt_dataptr))
    tmp_nrecords = self.dt_nrecords


    ; open or create the file

    if fn_exists then begin

        fid = h5f_open(filename, /WRITE)
        
    endif else begin
        
        fid = h5f_create(filename)
        
    endelse


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


    self -> Vtable_Close
        

    return, 1

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


function wmb_DataTable::Vtable_Open


    compile_opt idl2, strictarrsubs

        
    loc_id = self.dt_vtable_loc_id
        
    if self.dt_vtable_open eq 0 then begin
        
        filename = self.dt_vtable_filename
        groupname = self.dt_full_group_name
        
        fid = h5f_open(filename,/WRITE)
        loc_id = h5g_open(fid, groupname)
    
        self.dt_vtable_fid = fid
        self.dt_vtable_loc_id = loc_id
    
        self.dt_vtable_open = 1
    
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

    self->IDL_Object::GetProperty, _Extra=extra
    
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
;   If the NOCOPY keyword is set to 1, the input data variable 
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
                              Nocopy=nocopy, $
                              RecordDef=recorddef, $
                              Title = title
                              

    compile_opt idl2, strictarrsubs


    if N_elements(nocopy) eq 0 then nocopy = 0

    if N_elements(title) eq 0 then title = 'Table'

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
    
    self.dt_dataptr                = ptr_new()
  
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
        
    endif


    if indata_present then inittype = 'inputvar' $
                      else inittype = 'empty_table'


    case inittype of

        'inputvar': begin

            if ~self->Append(indata, nocopy=nocopy) then return, 0

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

    ptr_free, self.dt_record_def_ptr
    ptr_free, self.dt_dataptr
    
    if self.dt_flag_vtable && self.dt_vtable_open then begin
        
        h5g_close, self.dt_vtable_loc_id
        h5f_close, self.dt_vtable_fid
        
    endif

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
                                                           $
        dt_nfields                  : long64(0),           $
        dt_nrecords                 : long64(0),           $
                                                           $                                                  
        dt_dataptr                  : ptr_new(),           $
                                                           $
        dt_flag_vtable              : fix(0),              $
        dt_vtable_filename          : '',                  $
        dt_vtable_open              : fix(0),              $
        dt_vtable_fid               : long(0),             $
        dt_vtable_loc_id            : long(0),             $
                                                           $
        dt_flag_table_empty         : fix(0)               }

end

