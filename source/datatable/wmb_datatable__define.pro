

;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   Overload array indexing for the wmb_DataTable object
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_DataTable::_overloadBracketsRightSide, isRange, sub1, $
    sub2, sub3, sub4, sub5, sub6, sub7, sub8

    compile_opt idl2, strictarrsubs
    @dv_func_err_handler


    if N_elements(sub1) eq 0 then begin
        message, 'No array subscript specified'
        return, 0
    endif

    if N_elements(sub2) eq 0 then sub2=[0,0,1]
    if N_elements(sub3) eq 0 then sub3=[0,0,1]
    if N_elements(sub4) eq 0 then sub4=[0,0,1]
    if N_elements(sub5) eq 0 then sub5=[0,0,1]
    if N_elements(sub6) eq 0 then sub6=[0,0,1]
    if N_elements(sub7) eq 0 then sub7=[0,0,1]
    if N_elements(sub8) eq 0 then sub8=[0,0,1]


    ; determine the number of indices/ranges specified
    n_inputs = N_elements(isrange)

    if n_inputs eq 0 then begin
        message, 'No array subscript specified'
        return, 0
    endif


    ; make a list of the input indices/ranges
    inputlist = list(sub1,sub2,sub3,sub4,sub5,sub6,sub7,sub8)


    ; test validity of indices and ranges
    chkpass = 1
    for i = 0, n_inputs-1 do begin
        if isrange[i] eq 1 then begin
            tmpinput = inputlist[i]
            if ~ self->Rangevalid( tmpinput, i ) then chkpass = 0
        endif else begin
            tmpinput = inputlist[i]
            if ~ self->Indexvalid( tmpinput, i ) then chkpass = 0
        endelse
    endfor

    if chkpass eq 0 then begin
        message, 'Array subscript out of range'
        return, 0
    endif


    ; check that the correct number of subscripts have been provided
    if n_inputs ne self.ds_rank then begin
        message, 'Invalid number of array subscripts'
        return, 0
    endif



end

;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   This is the AppendRecords method
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_DataTable::AppendRecords, indata

    compile_opt idl2, strictarrsubs

    if N_elements(indata) eq 0 then message, 'Error: no input data'

    if self.dt_flag_vtable then begin
        
        ; write the new records to disk
        
        loc_id = self.dt_vtable_loc_id
        dset_name = self.dt_dataset_name
        nrecords = N_elements(indata)
        
        wmb_h5tb_append_records, loc_id, $
                                 dset_name, $
                                 nrecords, $
                                 databuffer

    endif else begin
        
        ; add the new records to memory
        
        tmpdat = temporary(*(self.dt_dataptr))
        ptr_free, self.dt_dataptr
        newdat = [temporary(tmpdat),indata]
        self.dt_nrecords = N_elements(newdat)
        self.dt_dataptr = ptr_new(newdat, /no_copy)
        
    endelse

    
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
                              Title = title, $
                              DatasetName = dset_name, $
                              OverwriteFlag = overwriteflag, $
                              Chunksize = chunksize, $
                              CompressFlag = compressflag

    
    compile_opt idl2, strictarrsubs
    
    if N_elements(filename) eq 0 then begin
        message, 'Error: invalid filename'
        return, 0
    endif

    if N_elements(title) eq 0 then title = self.dt_title
    if N_elements(dset_name) eq 0 then dset_name = self.dt_dataset_name
    if N_elements(overwriteflag) eq 0 then overwriteflag = 0
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
 
    if size(title,/type) ne 7 or size(dset_name,/type) ne 7 then begin
        message, 'Error: Title and DatasetName must be scalar strings'
        return, 0
    endif

    if size(title,/n_dimensions) ne 0 or $
       size(dset_name,/n_dimensions) ne 0 then begin
        message, 'Error: Title and DatasetName must be scalar strings'
        return, 0
    endif

    ; check if filename exists and is writable
    
    fn_exists = (file_info(filename)).exists

    if fn_exists then fn_writable = file_test(fn, /WRITE) $
                 else fn_writable = 0

    ; delete the file if it exists (overwrite flag must be specified)

    if fn_exists then begin
        
        if overwriteflag then begin
            
            if ~fn_writable then begin
                
                message, 'Error: cannot overwrite existing file'
                return, 0
            
            endif else begin
                
                ; delete the file
                file_delete, filename
                
            endelse
            
        endif else begin
            
            message, 'Error: file exists'
            return, 0
            
        endelse

    endif
    
    ; we now have a valid filename, title, and dataset name
    
    tmp_recdef = *(self.dt_record_def_ptr)
    tmp_data = temporary(*(self.dt_dataptr))
    tmp_nrecords = self.dt_nrecords
    
    ; create the file
    
    fid = h5f_create(filename)
    
    ; write the table
    
    wmb_h5tb_make_table, title, $
                         fid, $
                         dset_name, $
                         tmp_nrecords, $
                         tmp_recdef, $
                         chunksize, $
                         compress, $
                         databuffer = tmp_data
    

    ; we are done!  populate the self fields

    self.dt_dataset_name = dset_name
    self.dt_title = title
    self.dt_flag_vtable = 1
    self.vtable_filename = filename
    self.dt_vtable_loc_id = fid


    ; note that we are leaving the file open - when the table is in vtable
    ; mode, the file will only be closed when the object is destroyed

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


function wmb_DataTable::Load, filename, dset_name

    compile_opt idl2, strictarrsubs

    if N_elements(filename) eq 0 then begin
        message, 'Error: invalid filename'
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

    fn_exists = (file_info(filename)).exists

    if fn_exists then fn_writable = file_test(fn, /WRITE) $
                 else fn_writable = 0

    if fn_exists and fn_writable then fn_is_hdf5 = h5f_is_hdf5(filename) $
                                 else fn_is_hdf5 = 0

    if ~fn_exists or $
       ~fn_writable or $
       ~fn_is_hdf5 then begin
        
        message, 'Error: invalid HDF5 file'
        return, 0
        
    endif

    ; verify that the dataset exists
    
    dset_exists = wmb_h5_dataset_exists(filename,dset_name)

    if ~dset_exists then begin
        
        message, 'Error: HDF5 dataset not found'
        return, 0
        
    endif

    ; this appears to be a valid HDF5 file and the specfied dataset exists
    
    ; open the file
    
    fid = h5f_open(filename, /WRITE)
    loc_id = fid

    ; verify that this dataset is a table

    wmb_h5lt_get_attribute_disk, loc_id, 'CLASS', dset_class
    
    if strupcase(dset_class) ne 'TABLE' then begin

        message, 'Error: HDF5 dataset is not a table type'
        return, 0

    endif

    ; get information about the table size
    
    wmb_h5tb_get_table_info, loc_id, dset_name, nfields, nrecords

    ; get the record data structure
    
    wmb_h5tb_get_field_info, loc_id, dset_name, record_definition

    ; get the table title
    
    wmb_h5tba_get_title, loc_id, table_title
    

    ; we are done!  populate the self fields
    
    self.dt_dataset_name = dset_name
    self.dt_title = table_title
    self.dt_record_def_ptr = ptr_new(record_definition)
    self.dt_flag_record_def_init = 1
    self.dt_nfields = nfields
    self.dt_nrecords = nrecords
    self.dt_flag_vtable = 1
    self.vtable_filename = filename
    self.dt_vtable_loc_id = loc_id
    self.dt_flag_table_empty = 0

    ; note that we are leaving the file open - when the table is in vtable
    ; mode, the file will only be closed when the object is destroyed

    return, 1

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
;   If the DATACOPY keyword is set to 1, a copy of the data will
;   be created before it is stored in the object.  Otherwise, the
;   input data variable will be undefined after the object is
;   created.
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
                              Datacopy=datacopy, $
                              RecordDef=recorddef, $
                              Title = title, $
                              DatasetName = dset_name

    compile_opt idl2, strictarrsubs


    ;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
    ;
    ;   Check that the positional parameters are present.
    ;


    ;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
    ;
    ;   Check which keyword parameters are present.
    ;

    if N_elements(datacopy) eq 0 then datacopy = 0
    if N_elements(title) eq 0 then title = 'Table'
    if N_elements(dset_name) eq 0 then dset_name = 'Data'
    
    if size(title,/type) ne 7 or size(dset_name,/type) ne 7 then $
        message, 'Error: Title and DatasetName must be scalar strings'
        
    if size(title,/n_dimensions) ne 0 or $
       size(dset_name,/n_dimensions) ne 0 then $
       message, 'Error: Title and DatasetName must be scalar strings'

    indata_present = N_elements(indata) ne 0
    recorddef_present = N_elements(recorddef) ne 0
    
    
    ; check the input data
    
    if indata_present then begin
        
        indata_is_struct = size(indata,/type) eq 8
        
        if ~indata_is_struct then $
            message, 'Error: Indata must be a structure type'
            
        if size(indata,/n_dimensions) gt 1 then $
            message, 'Error: Input data must be 1-dimensional'
        
    endif
    
    
    ; check the record definition
        
    if recorddef_present then begin
        
        recorddef_is_struct = size(indata,/type) eq 8
        
        if recorddef_is_struct then recorddef_ntags = n_tags(indata) $
                               else recorddef_ntags = 0
                         
        if size(recorddef,/n_dimensions) gt 1 then $
            message, 'Error: Record definition must be scalar'
            
        if size(recorddef,/dimensions) gt 1 then $
            message, 'Error: Record definition must be scalar'
                         
        ; If both input data and a record definition are provided, check
        ; to ensure that the strucure types are identical (including field
        ; names).
                            
        if indata_present then begin
            
            firstrec = indata[0]
            
            type_matched = wmb_compare_struct(firstrec, recorddef, $
                                              /compare_field_names, $
                                              /ignore_field_values)
                                              
            if ~type_matched then $
                message, 'Error: Input data type and record definition ' + $
                         'do not match'
            
        endif
        
    endif
        
    ; initialize variables that will be stored in self
    
    tmp_recorddefptr = ptr_new()
    tmp_recorddef_init = 0
    tmp_nfields = 0
    tmp_nrecords = 0
    tmp_dataptr = ptr_new()
    tmp_table_empty = 1
    

    if indata_present then inittype = 'inputvar' $
                      else inittype = 'empty_table'

    case inittype of

        'inputvar': begin

            ; the object has been initialized with a data variable - measure its
            ; dimensions and store a pointer to the data

            ; create a record definition if necessary
            
            if recorddef_present then begin
                
                tmp_recorddefptr = ptr_new(recorddef)
                
            endif else begin
                
                tmp_recorddef = wmb_h5tb_data_to_record_definition(indata)
                tmp_recorddefptr = ptr_new(tmp_recorddef)
                
            endelse
            
            tmp_recorddef_init = 1
            
            tmp_nfields = n_tags(indata)
            tmp_nrecords = size(indata, /dimensions)

            if datacopy eq 1 then begin

                tmpdata = indata

            endif else begin

                tmpdata = temporary(indata)

            endelse

            tmp_dataptr = ptr_new(tmpdata, /NO_COPY)
            
            tmp_table_empty = 0

        end


        'empty_table': begin
            
            if recorddef_present then begin
                
                tmp_recorddefptr = ptr_new(recorddef)
                tmp_recorddef_init = 1
                
                tmp_nfields = n_tags(recorddef)
                
            endif
            
        end
        
    endcase

    ;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
    ;
    ;   populate the self fields
    ;


    self.dt_dataset_name           = dset_name
    self.dt_title                  = title
    self.dt_record_def_ptr         = tmp_recorddefptr
    self.dt_flag_record_def_init   = tmp_recorddef_init
     
    self.dt_nfields                = tmp_nfields
    self.dt_nrecords               = tmp_nrecords
    
    self.dt_dataptr                = tmp_dataptr
  
    self.dt_flag_vtable            = 0
    self.dt_vtable_filename        = ''
    self.dt_vtable_loc_id          = 0
    
    self.dt_flag_table_empty       = tmp_table_empty


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
    if self.dt_flag_vtable then h5f_close, slef.dt_vtable_loc_id

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
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


pro wmb_DataTable__define

    compile_opt idl2, strictarrsubs


    struct = { wmb_DataTable,                              $
        INHERITS IDL_Object,                               $
                                                           $
        dt_dataset_name             : '',                  $
        dt_title                    : '',                  $
                                                           $
        dt_record_def_ptr           : ptr_new(),           $
        dt_flag_record_def_init     : fix(0),              $
                                                           $
        dt_nfields                  : ulong64(0),          $
        dt_nrecords                 : ulong64(0),          $
                                                           $                                                  
        dt_dataptr                  : ptr_new(),           $
                                                           $
        dt_flag_vtable              : fix(0),              $
        dt_vtable_filename          : '',                  $
        dt_vtable_loc_id            : long(0),             $
                                                           $
        dt_flag_table_empty         : fix(0)               }

end

