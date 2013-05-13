
; wmb_h5tb_examples
;
; Purpose: Demonstrate reading/writing/modification of HDF5 tables in IDL.
;
; Description:  The wmb_hdf5* library implements the basic functions for 
;               reading and writing HDF5 tables from IDL.  This library was
;               created by porting the C code from the HDF5 distribution
;               (H5TB.c, from HDF5 version 1.8.10) and modifying it to work 
;               with the HDF5 API currently supported by IDL (as of IDL 
;               version 8.2, most of the HDF5 version 1.6 API is supported).
;           
;       The C source code which this library is based on can be found
;       at the following location:
;       
;       http://www.hdfgroup.org/ftp/HDF5/current/src/unpacked/hl/src/H5TB.c
;
;       By translating this code into IDL, the following functions were ported:
;           
;       Table creation:
;       
;           wmb_h5tb_make_table.pro
;
;       Storage:
;       
;           wmb_h5tb_append_records.pro
;           wmb_h5tb_write_records.pro
;           wmb_h5tb_write_fields_index.pro
;           wmb_h5tb_write_fields_name.pro
;           
;       Retrieval: 
;       
;           wmb_h5tb_read_table.pro
;           wmb_h5tb_read_records.pro
;           wmb_h5tb_read_fields_index.pro
;           wmb_h5tb_read_fields_name.pro
;           
;       Query:
;       
;           wmb_h5tb_get_table_info.pro
;           wmb_h5tb_get_field_info.pro
;           
;       Modification:
;       
;           wmb_h5tb_insert_records.pro
;           wmb_h5tb_add_records_from.pro
;           wmb_h5tb_combine_tables.pro
;
;       Several of the H5TB* functiions from the could not
;       be ported, due to limitations of the current version of the 
;       IDL HDF5 implementation.  These functions are listed below, 
;       along with the reasons why they could not be ported.
;       
;       H5TB_delete_record:  Currently, IDL does not implement the
;                            H5D_set_extent function, and therefore
;                            there is no way to reduce the size of
;                            an existing dataset.
;
;       H5TB_insert_field:   The version of H5D_write implemented by
;       and                  IDL does not allow the specification of 
;       H5TB_delete_field    a "write datatype id", which is required
;                            to enable the selective writing of a subset
;                            of the fields within a table.  Also, IDL does 
;                            not allow the chunk dimensions and the 
;                            compression state of an existing dataset 
;                            to be queried.
;                                

                                
             
pro wmb_h5tb_examples

    fn = 'C:\Mark\SkyDrive\Code\IDLcode\DaxView\test_data\sample_OBF_data\tabletest.h5'
    dset_name = 'markstable'
    
    fid = h5f_open(fn,/WRITE)
    
    loc_id = fid
    
;    overwrite_field_index = [1,2]
;    overwrite_field_names = ['firstcol']
;    
;    start = 8
;    nrecords=3
;    
;    ra = {a:0,b:0.0,c:'total'}
;    rb = replicate(ra,nrecords)
;    rb.(0)[0] = findgen(nrecords) + 555
;    rb.(1)[*] = 45.23
;    rb.(2)[*] = 'total'
;    databuffer = rb
;    
;    wmb_h5tb_insert_records, loc_id, $
;                            dset_name, $
;                            start, $
;                            nrecords, $
;                            databuffer

;    start = 4
;    nrecords = 10
;    read_field_index = [2,0]
;    read_field_name = ['thirdcol','firstcol']
;
;    wmb_h5tb_read_fields_name, loc_id, $
;                                dset_name, $
;                                read_field_name, $
;                                start, $
;                                nrecords, $
;                                databuffer
;
;    print, databuffer

    start = 1000
    nrecords = 3

    wmb_h5tb_delete_record, loc_id, $
                            dset_name, $
                            start, $
                            nrecords

    h5f_close, fid
    
    
end