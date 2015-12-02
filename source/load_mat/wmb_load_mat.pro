;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_load_mat
;
;   This is a modified version of the "load_mat" routine, 
;   written by Gordon Farquharson.  This version loads a wider
;   range of data types, including compressed data.  The
;   original release notes by GF are included here:
;   
;   This routine allows one to read MATLAB MAT-files in IDL. I've only
;   tested it on very specific .mat files so far, and not all variable
;   types are supported yet. However, the code is written in such a way
;   that one should be able to easily extend it so that it reads the other
;   objects MATLAB can store in a .mat file. If you'd like me to add
;   something, send me a .mat file and I'll try to make it work.
;   
;   This routine only reads Level 5 .mat files [1] - it doesn't read
;   HDF-based MATLAB format.
;   
;   Usage:
;   
;   PRO load_mat, <filename>, STORE_LEVEL=store_level, $
;                 VERBOSE=verbose, DEBUG=debug
;   
;   By default, it will create the variables on the $MAIN$ level. To have
;   the routine only create variables in your program's context, use
;   STORE_LEVEL=-1 in your program. See the (undocumented) IDL function
;   ROUTINE_NAMES for more information [2, 3].
;   
;   [1] http://www.mathworks.com/access/helpdesk/help/pdf_doc/matlab
;             /matfile_format.pdf
;   [2] http://www.physics.wisc.edu/~craigm/idl/down/routine_names.pro
;   [3] http://www.idlcoyote.com/tips/access_main_vars.html
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


FUNCTION element_tag_struct

    return, { mat_v5_element_tag, $
              data_type             : 0UL, $
              data_type_description : '', $
              data_symbol           : '', $
              number_of_bytes       : 0UL, $
              small_element_format  : 0B $
            }

END


FUNCTION subelement_array_flags_struct

    return, { mat_v5_subelement_array_flags, $
              flag_word_1 : 0UL, $
              flag_word_2 : 0UL, $
              complex     : 0B, $
              global      : 0B, $
              logical     : 0B, $
              class       : 0B, $
              class_description : '', $
              class_symbol      : '' $
            }

END


FUNCTION subelement_dimensions_array_struct

    ;; IDL allows a maximum of 8 dimensions.

    return, { mat_v5_subelement_dimensions_array, $
              number_of_dimensions : 0L, $
              dimensions           : lonarr(8) $
            }

END

FUNCTION size_of_data_type, data_symbol

    SWITCH data_symbol OF
        'miINT8'   :
        'miUINT8'  :
        'miUTF8'   : return, 1
        'miINT16'  :
        'miUINT16' :
        'miUTF16'  : return, 2
        'miINT32'  :
        'miUINT32' :
        'miUTF32'  :
        'miSINGLE' : return, 4
        'miINT64'  :
        'miUINT64' :
        'miDOUBLE' : return, 8
    ENDSWITCH

END

FUNCTION mat_type_to_idl, data_symbol

    CASE data_symbol OF
        'miINT8'   : return, 1
        'miUINT8'  : return, 1
        'miUTF8'   : return, 1
        'miINT16'  : return, 2
        'miUINT16' : return, 12
        'miUTF16'  : return, 2
        'miINT32'  : return, 3
        'miUINT32' : return, 13
        'miUTF32'  : return, 3
        'miSINGLE' : return, 4
        'miINT64'  : return, 14 
        'miUINT64' : return, 15 
        'miDOUBLE' : return, 5
    ENDCASE

END

FUNCTION cast_to_matrix_type, input_data, matrix_class

    CASE matrix_class OF
        'mxCHAR_CLASS'   : return, string(byte(temporary(input_data)))
        'mxDOUBLE_CLASS' : return, double(temporary(input_data))
        'mxSINGLE_CLASS' : return, float(temporary(input_data))
        'mxINT8_CLASS'   : return, byte(temporary(input_data))
        'mxUINT8_CLASS'  : return, byte(temporary(input_data))
        'mxINT16_CLASS'  : return, fix(temporary(input_data))
        'mxUINT16_CLASS' : return, uint(temporary(input_data))
        'mxINT32_CLASS'  : return, long(temporary(input_data))
        'mxUINT32_CLASS' : return, ulong(temporary(input_data))
        'mxINT64_CLASS'  : return, long64(temporary(input_data))
        'mxUINT64_CLASS' : return, ulong64(temporary(input_data))
    ENDCASE

END


PRO skip_padding_bytes_disk, lun, DEBUG=debug

    ;; All data elements are aligned on a 64 bit boundary. Calculate
    ;; how many padding bytes exist, and advance the file pointer
    ;; appropriately.

    point_lun, -lun, position

    IF (position MOD 8) NE 0 THEN BEGIN

        number_of_padding_bytes = 8 - (position MOD 8)

        IF keyword_set(debug) THEN $
            print, 'Skipping ', number_of_padding_bytes, ' bytes'

        new_position = position + number_of_padding_bytes
        
        point_lun, lun, new_position

    ENDIF

END

PRO skip_padding_bytes_memory, mem_read_ptr, DEBUG=debug

    ;; All data elements are aligned on a 64 bit boundary. Calculate
    ;; how many padding bytes exist, and advance the read pointer
    ;; appropriately.

    IF (mem_read_ptr MOD 8) NE 0 THEN BEGIN

        number_of_padding_bytes = 8 - (mem_read_ptr MOD 8)

        IF keyword_set(debug) THEN $
            print, 'Skipping ', number_of_padding_bytes, ' bytes'

        mem_read_ptr = mem_read_ptr + number_of_padding_bytes

    ENDIF

END



PRO read_element_tag_disk, lun, $
                           element_struct, $
                           SWAP_ENDIAN=swap_endian, $
                           DEBUG=debug


    ; these are 4-byte variable types
    
    data_type = 0UL
    number_of_bytes = 0UL

    readu, lun, data_type

    IF swap_endian THEN swap_endian_inplace, data_type


    IF (data_type AND 'FFFF0000'XUL) EQ 0UL THEN BEGIN

        readu, lun, number_of_bytes
            
        IF swap_endian THEN swap_endian_inplace, number_of_bytes


        element_struct.data_type = data_type
        element_struct.number_of_bytes = number_of_bytes
        element_struct.small_element_format = 0B

    ENDIF ELSE BEGIN

        ;; Small data element format

        element_struct.number_of_bytes = $
            ishft(data_type AND 'FFFF0000'XUL, -16)
        element_struct.data_type = data_type AND '0000FFFF'XUL
        element_struct.small_element_format = 1B

    ENDELSE


    data_type_description = ''
    data_symbol = ''

    CASE element_struct.data_type OF
        1  : BEGIN
            data_type_description = '8 bit, signed'
            data_symbol = 'miINT8'
        END
        2  : BEGIN
            data_type_description = '8 bit, unsigned'
            data_symbol = 'miUINT8'
        END
        3  : BEGIN
            data_type_description = '16 bit, signed'
            data_symbol = 'miINT16'
        END
        4  : BEGIN
            data_type_description = '16 bit, unsigned'
            data_symbol = 'miUINT16'
        END
        5  : BEGIN
            data_type_description = '32 bit, signed'
            data_symbol = 'miINT32'
        END
        6  : BEGIN
            data_type_description = '32 bit, unsigned'
            data_symbol = 'miUINT32'
        END
        7  : BEGIN
            data_type_description = 'IEEE 754 single format'
            data_symbol = 'miSINGLE'
        END
        8  : BEGIN
            data_type_description = 'Reserved (8)'
            data_symbol = ''
        END
        9  : BEGIN
            data_type_description = 'IEEE 754 double format'
            data_symbol = 'miDOUBLE'
        END
        10 : BEGIN
            data_type_description = 'Reserved'
            data_symbol = ''
        END
        11 : BEGIN
            data_type_description = 'Reserved'
            data_symbol = ''
        END
        12 : BEGIN
            data_type_description = '64 bit, signed'
            data_symbol = 'miINT64'
        END
        13 : BEGIN
            data_type_description = '64 bit, unsigned'
            data_symbol = 'miUINT64'
        END
        14 : BEGIN
            data_type_description = 'MATLAB array'
            data_symbol = 'miMATRIX'
        END
        15 : BEGIN
            data_type_description = 'Compressed data'
            data_symbol = 'miCOMPRESSED'
        END
        16 : BEGIN
            data_type_description = 'Unicode UTF-8 encoded character data'
            data_symbol = 'miUTF8'
        END
        17 : BEGIN
            data_type_description = 'Unicode UTF-16 encoded character data'
            data_symbol = 'miUTF16'
        END
        18 : BEGIN
            data_type_description = 'Unicode UTF-32 encoded character data'
            data_symbol = 'miUTF32'
        END
    ENDCASE

    element_struct.data_type_description = data_type_description
    element_struct.data_symbol = data_symbol

    IF element_struct.small_element_format THEN $
        small_element_text = 'True' $
    ELSE $
        small_element_text = 'False'

    IF keyword_set(DEBUG) THEN BEGIN
        print, 'Data type       : ', element_struct.data_type_description
        print, 'Data symbol     : ', element_struct.data_symbol
        print, 'Number of bytes : ', element_struct.number_of_bytes
        print, 'Small element   : ', small_element_text
    ENDIF

END



PRO read_element_tag_memory, input_bytarr, $
                             mem_read_ptr, $
                             element_struct, $
                             SWAP_ENDIAN=swap_endian, $
                             DEBUG=debug


    ; these are 4-byte variable types
    
    data_type = 0UL
    number_of_bytes = 0UL

    data_type = ulong(input_bytarr,mem_read_ptr)
    mem_read_ptr = mem_read_ptr + 4UL

    IF swap_endian THEN swap_endian_inplace, data_type


    IF (data_type AND 'FFFF0000'XUL) EQ 0UL THEN BEGIN

        number_of_bytes = ulong(input_bytarr,mem_read_ptr)
        mem_read_ptr = mem_read_ptr + 4UL
            
        IF swap_endian THEN swap_endian_inplace, number_of_bytes

        element_struct.data_type = data_type
        element_struct.number_of_bytes = number_of_bytes
        element_struct.small_element_format = 0B

    ENDIF ELSE BEGIN

        ;; Small data element format

        element_struct.number_of_bytes = $
            ishft(data_type AND 'FFFF0000'XUL, -16)
        element_struct.data_type = data_type AND '0000FFFF'XUL
        element_struct.small_element_format = 1B

    ENDELSE


    data_type_description = ''
    data_symbol = ''

    CASE element_struct.data_type OF
        1  : BEGIN
            data_type_description = '8 bit, signed'
            data_symbol = 'miINT8'
        END
        2  : BEGIN
            data_type_description = '8 bit, unsigned'
            data_symbol = 'miUINT8'
        END
        3  : BEGIN
            data_type_description = '16 bit, signed'
            data_symbol = 'miINT16'
        END
        4  : BEGIN
            data_type_description = '16 bit, unsigned'
            data_symbol = 'miUINT16'
        END
        5  : BEGIN
            data_type_description = '32 bit, signed'
            data_symbol = 'miINT32'
        END
        6  : BEGIN
            data_type_description = '32 bit, unsigned'
            data_symbol = 'miUINT32'
        END
        7  : BEGIN
            data_type_description = 'IEEE 754 single format'
            data_symbol = 'miSINGLE'
        END
        8  : BEGIN
            data_type_description = 'Reserved (8)'
            data_symbol = ''
        END
        9  : BEGIN
            data_type_description = 'IEEE 754 double format'
            data_symbol = 'miDOUBLE'
        END
        10 : BEGIN
            data_type_description = 'Reserved'
            data_symbol = ''
        END
        11 : BEGIN
            data_type_description = 'Reserved'
            data_symbol = ''
        END
        12 : BEGIN
            data_type_description = '64 bit, signed'
            data_symbol = 'miINT64'
        END
        13 : BEGIN
            data_type_description = '64 bit, unsigned'
            data_symbol = 'miUINT64'
        END
        14 : BEGIN
            data_type_description = 'MATLAB array'
            data_symbol = 'miMATRIX'
        END
        15 : BEGIN
            data_type_description = 'Compressed data'
            data_symbol = 'miCOMPRESSED'
        END
        16 : BEGIN
            data_type_description = 'Unicode UTF-8 encoded character data'
            data_symbol = 'miUTF8'
        END
        17 : BEGIN
            data_type_description = 'Unicode UTF-16 encoded character data'
            data_symbol = 'miUTF16'
        END
        18 : BEGIN
            data_type_description = 'Unicode UTF-32 encoded character data'
            data_symbol = 'miUTF32'
        END
    ENDCASE

    element_struct.data_type_description = data_type_description
    element_struct.data_symbol = data_symbol

    IF element_struct.small_element_format THEN $
        small_element_text = 'True' $
    ELSE $
        small_element_text = 'False'

    IF keyword_set(DEBUG) THEN BEGIN
        print, 'Data type       : ', element_struct.data_type_description
        print, 'Data symbol     : ', element_struct.data_symbol
        print, 'Number of bytes : ', element_struct.number_of_bytes
        print, 'Small element   : ', small_element_text
    ENDIF

END




PRO read_subelement_array_flags_memory, input_data, $
                                        mem_read_ptr, $
                                        subelement_struct, $
                                        SWAP_ENDIAN=swap_endian, $
                                        DEBUG=debug

    ; these are 4-byte variables

    array_flags = ulong(input_data,mem_read_ptr,2)
    mem_read_ptr = mem_read_ptr + 8UL    

    flags1 = array_flags[0]
    flags2 = array_flags[1]

    IF swap_endian THEN swap_endian_inplace, flags1
    IF swap_endian THEN swap_endian_inplace, flags2

    subelement_struct.flag_word_1 = flags1
    subelement_struct.flag_word_2 = flags2
    subelement_struct.complex = flags1 AND '00000800'XL
    subelement_struct.global = flags1 AND '00000400'XL
    subelement_struct.logical = flags1 AND '00000200'XL
    subelement_struct.class = flags1 AND '000000FF'XL

    IF keyword_set(debug) THEN BEGIN
        print, 'Complex           : ', subelement_struct.complex
        print, 'Global            : ', subelement_struct.global
        print, 'Logical           : ', subelement_struct.logical
    ENDIF

    class_description = ''
    class_symbol = ''

    CASE subelement_struct.class OF
        1 : BEGIN
            class_description = 'Cell array'
            class_symbol = 'mxCELL_CLASS'
        END
        2 : BEGIN
            class_description = 'Structure'
            class_symbol = 'mxSTRUCT_CLASS'
        END
        3 : BEGIN
            class_description = 'Object'
            class_symbol = 'mxOBJECT_CLASS'
        END
        4 : BEGIN
            class_description = 'Character array'
            class_symbol = 'mxCHAR_CLASS'
        END
        5 : BEGIN
            class_description = 'Sparse array'
            class_symbol = 'mxSPARSE_CLASS'
        END
        6 : BEGIN
            class_description = 'Double precision array'
            class_symbol = 'mxDOUBLE_CLASS'
        END
        7 : BEGIN
            class_description = 'Single precision array'
            class_symbol = 'mxSINGLE_CLASS'
        END
        8 : BEGIN
            class_description = '8-bit, signed integer'
            class_symbol = 'mxINT8_CLASS'
        END
        9 : BEGIN
            class_description = '8-bit, unsigned integer'
            class_symbol = 'mxUINT8_CLASS'
        END
        10 : BEGIN
            class_description = '16-bit, signed integer'
            class_symbol = 'mxINT16_CLASS'
        END
        11 : BEGIN
            class_description = '16-bit, unsigned integer'
            class_symbol = 'mxUINT16_CLASS'
        END
        12 : BEGIN
            class_description = '32-bit, signed integer'
            class_symbol = 'mxINT32_CLASS'
        END
        13 : BEGIN
            class_description = '32-bit, unsigned integer'
            class_symbol = 'mxUINT32_CLASS'
        END
        14 : BEGIN
            class_description = '64-bit, signed integer'
            class_symbol = 'mxINT64_CLASS'
        END
        15 : BEGIN
            class_description = '64-bit, unsigned integer'
            class_symbol = 'mxUINT64_CLASS'
        END        
    ENDCASE

    subelement_struct.class_description = class_description
    subelement_struct.class_symbol = class_symbol

    IF keyword_set(debug) THEN BEGIN
        print, 'Class description : ', subelement_struct.class_description
        print, 'Class symbol      : ', subelement_struct.class_symbol
    ENDIF

END




PRO read_subelement_dimensions_array_memory, input_data, $
                                             mem_read_ptr, $
                                             subelement_tag, $
                                             subelement_struct, $                                        
                                             SWAP_ENDIAN=swap_endian, $
                                             DEBUG=debug


    number_of_dimensions = subelement_tag.number_of_bytes / $
                           size_of_data_type(subelement_tag.data_symbol)

    subelement_struct.number_of_dimensions = number_of_dimensions
    
    ;; I don't know if this case statement is necessary. The
    ;; documentation is not clear on whether the dimensions array type
    ;; is always miINT32.

    dim_array = lonarr(number_of_dimensions)

    CASE size_of_data_type(subelement_tag.data_symbol) OF
        1 : begin
            dimension = 0B
            dim_var_type_size = 1
            dim_var_idl_type = 1
        end
        2 : begin
            dimension = 0
            dim_var_type_size = 2
            dim_var_idl_type = 2
        end
        4 : begin
            dimension = 0L
            dim_var_type_size = 4
            dim_var_idl_type = 3
        end
    ENDCASE

    FOR i = 0, number_of_dimensions-1 DO BEGIN
        
        dimension = fix(input_data, mem_read_ptr, type=dim_var_idl_type)
        mem_read_ptr = mem_read_ptr + dim_var_type_size

        IF swap_endian THEN swap_endian_inplace, dimension

        dim_array[i] = dimension
        
    ENDFOR

    subelement_struct.dimensions = dim_array

    IF keyword_set(debug) THEN BEGIN
        print, 'Number of dimensions : ', subelement_struct.number_of_dimensions
        print, 'Dimensions           : ', subelement_struct.dimensions
    ENDIF

    skip_padding_bytes_memory, mem_read_ptr, DEBUG=debug

END


PRO read_subelement_array_name_memory, input_data, $
                                       mem_read_ptr, $
                                       subelement_tag, $
                                       array_name, $   
                                       SWAP_ENDIAN=swap_endian, $
                                       DEBUG=debug


    ;; Assume that data type is always miINT8.

    data_n_bytes = subelement_tag.number_of_bytes

    if data_n_bytes gt 0 then begin
        
        array_name_bytes = input_data[mem_read_ptr:mem_read_ptr+(data_n_bytes-1)]
        mem_read_ptr = mem_read_ptr + data_n_bytes

        array_name = string(array_name_bytes)

    endif else begin
        
        array_name = ''
        
    endelse
    
    IF keyword_set(debug) THEN print, 'Array name : ', array_name

    skip_padding_bytes_memory, mem_read_ptr, DEBUG=debug

END


PRO read_subelement_field_length_memory, input_data, $
                                         mem_read_ptr, $
                                         subelement_tag, $
                                         field_length, $   
                                         SWAP_ENDIAN=swap_endian, $
                                         DEBUG=debug


    ;; Assume that data type is always miINT32

    field_length = long(input_data, mem_read_ptr)
    mem_read_ptr = mem_read_ptr + 4UL

    skip_padding_bytes_memory, mem_read_ptr, DEBUG=debug

END


PRO read_subelement_field_names_memory, input_data, $
                                        mem_read_ptr, $
                                        field_names_data_tag, $                                        
                                        field_length, $   
                                        field_names_arr, $
                                        SWAP_ENDIAN=swap_endian, $
                                        DEBUG=debug

    number_of_fields = field_names_data_tag.number_of_bytes / field_length

    field_names_arr = strarr(number_of_fields)
    
    for i = 0, number_of_fields-1 do begin
        
        tmp_name_bytes = input_data[mem_read_ptr:mem_read_ptr+(field_length-1)]
        mem_read_ptr = mem_read_ptr + field_length
        
        field_names_arr[i] = string(tmp_name_bytes)
        
    endfor

    skip_padding_bytes_memory, mem_read_ptr, DEBUG=debug

END


FUNCTION read_mat_element_memory, element_tag_in, $
                                  raw_data_in, $
                                  mem_read_ptr, $
                                  output_var_name, $
                                  SWAP_ENDIAN = swap_endian, $
                                  DEBUG=debug

    data_symbol = element_tag_in.data_symbol
    data_size_bytes = element_tag_in.number_of_bytes
    output_var_name = ''

    IF keyword_set(debug) THEN BEGIN
        print
        print, '** Reading data of type ' + data_symbol + ', size: ', $
               data_size_bytes
               
    ENDIF

    SWITCH data_symbol OF

        'miUTF8':
        'miUTF16':
        'miUTF32':
        'miINT8':
        'miUINT8':
        'miINT16':
        'miUINT16':
        'miINT32':
        'miUINT32':
        'miSINGLE':
        'miDOUBLE':
        'miINT64':
        'miUINT64': begin
            
            data_type_size_bytes = size_of_data_type(data_symbol)
            data_type_idl = mat_type_to_idl(data_symbol)            
            number_of_elements = data_size_bytes / data_type_size_bytes
            
            if data_size_bytes gt 0 then begin
            
                data_out = fix(raw_data_in, $
                               mem_read_ptr, $
                               number_of_elements, $
                               TYPE = data_type_idl)
                
                mem_read_ptr = mem_read_ptr + data_size_bytes
                
                IF swap_endian THEN swap_endian_inplace, data_out
                
            endif else begin
                
                ; empty string
                
                data_out = ''
                
            endelse
            
            skip_padding_bytes_memory, mem_read_ptr, DEBUG=debug
            
            break 
        end
        

        'miMATRIX' : BEGIN

            ; Array flags subelement tag

            IF keyword_set(debug) THEN BEGIN
                print
                print, '* Array flags subelement tag'
            ENDIF

            array_flags_tag = element_tag_struct()
            
            read_element_tag_memory, raw_data_in, $
                                     mem_read_ptr, $
                                     array_flags_tag, $
                                     SWAP_ENDIAN=swap_endian, $
                                     DEBUG=debug

            ; Array flags subelement data

            IF keyword_set(debug) THEN BEGIN
                print
                print, '* Array flags subelement data'
            ENDIF

            array_flags_data = subelement_array_flags_struct()
            
            read_subelement_array_flags_memory, raw_data_in, $
                                                mem_read_ptr, $
                                                array_flags_data, $
                                                SWAP_ENDIAN=swap_endian, $
                                                DEBUG=debug
                                         
            matrix_class = array_flags_data.class_symbol
            chk_complex = array_flags_data.complex eq 1

            ;; Dimensions array subelement

            IF keyword_set(debug) THEN BEGIN
                print
                print, '* Dimensions array subelement tag'
            ENDIF

            dimensions_array_tag = element_tag_struct()
            
            read_element_tag_memory, raw_data_in, $
                                     mem_read_ptr, $
                                     dimensions_array_tag, $
                                     SWAP_ENDIAN=swap_endian, $
                                     DEBUG=debug


            IF keyword_set(debug) THEN BEGIN
                print
                print, '* Dimensions array subelement data'
            ENDIF

            dimensions_array_data = subelement_dimensions_array_struct()
            
            read_subelement_dimensions_array_memory, raw_data_in, $
                                                     mem_read_ptr, $
                                                     dimensions_array_tag, $
                                                     dimensions_array_data, $
                                                     SWAP_ENDIAN=swap_endian, $
                                                     DEBUG=debug

            out_ndims = dimensions_array_data.number_of_dimensions
            out_dims  = dimensions_array_data.dimensions[0:out_ndims-1]

            ;; Array name subelement

            IF keyword_set(debug) THEN BEGIN
                print
                print, '* Array name subelement tag'
            ENDIF

            array_name_tag = element_tag_struct()
            
            read_element_tag_memory, raw_data_in, $
                                     mem_read_ptr, $
                                     array_name_tag, $
                                     SWAP_ENDIAN=swap_endian, $
                                     DEBUG=debug

            IF keyword_set(debug) THEN BEGIN
                print
                print, '* Array name subelement data'
            ENDIF

            array_name = ''
            read_subelement_array_name_memory, raw_data_in, $
                                               mem_read_ptr, $ 
                                               array_name_tag, $
                                               array_name, $
                                               SWAP_ENDIAN=swap_endian, $
                                               DEBUG=debug

            total_elements = product(out_dims, /INTEGER)

            case matrix_class of
                
                'mxCELL_CLASS': begin
                    
                    ; we will import the cell array as an array of pointers
                    
                    if total_elements gt 0 then begin
                        
                        tmp_ptr_arr = ptrarr(total_elements)
                        
                        for i = 0, total_elements-1 do begin
                            
                            IF keyword_set(debug) THEN BEGIN
                                print
                                print, '* Cell subelement tag'
                            ENDIF
                            
                            cell_element_tag = element_tag_struct()
                            
                            read_element_tag_memory, raw_data_in, $
                                                     mem_read_ptr, $
                                                     cell_element_tag, $
                                                     SWAP_ENDIAN=swap_endian, $
                                                     DEBUG=debug
                            
                            IF keyword_set(debug) THEN BEGIN
                                print
                                print, '* Cell subelement data'
                            ENDIF
                            
                            cell_data = read_mat_element_memory(cell_element_tag, $
                                                        raw_data_in, $
                                                        mem_read_ptr, $
                                                        output_var_name, $
                                                        SWAP_ENDIAN=swap_endian, $
                                                        DEBUG=debug)
                            
                            tmp_ptr_arr[i] = ptr_new(cell_data, /NO_COPY)
                            
                        endfor
                        
                        ; reform the pointer array to have the correct dimensions,
                        ; and prevent 1x1 arrays from being created
                        
                        if size(tmp_ptr_arr, /N_ELEMENTS) eq 1 then begin
                            
                            data_out = tmp_ptr_arr[0]
                            
                        endif else begin
                            
                            data_out = reform(reform(tmp_ptr_arr, $
                                                     out_dims, $
                                                     /overwrite))
                            
                        endelse
                        
                    endif else begin
                        
                        ; zero length array of cells
                        
                        data_out = ''
                        
                    endelse
                        
                end
                
                'mxSTRUCT_CLASS': begin
                    
                    ; read the field name length subelement
                    
                    IF keyword_set(debug) THEN BEGIN
                        print
                        print, '* Struct subelement tag'
                    ENDIF
                    
                    field_name_length_tag = element_tag_struct()
                    
                    read_element_tag_memory, raw_data_in, $
                                             mem_read_ptr, $
                                             field_name_length_tag, $
                                             SWAP_ENDIAN=swap_endian, $
                                             DEBUG=debug
                    
                    IF keyword_set(debug) THEN BEGIN
                        print
                        print, '* Struct field length data'
                    ENDIF
                    
                    read_subelement_field_length_memory, raw_data_in, $
                                                     mem_read_ptr, $
                                                     field_name_length_tag, $
                                                     field_length, $   
                                                     SWAP_ENDIAN=swap_endian, $
                                                     DEBUG=debug
                    
                    IF keyword_set(debug) THEN BEGIN
                        print
                        print, '* Struct field names tag'
                    ENDIF
                    
                    field_names_data_tag = element_tag_struct()
                    
                    read_element_tag_memory, raw_data_in, $
                                             mem_read_ptr, $
                                             field_names_data_tag, $
                                             SWAP_ENDIAN=swap_endian, $
                                             DEBUG=debug
                    
                    IF keyword_set(debug) THEN BEGIN
                        print
                        print, '* Struct field names data'
                    ENDIF
                    
                    read_subelement_field_names_memory, raw_data_in, $
                                                     mem_read_ptr, $
                                                     field_names_data_tag, $
                                                     field_length, $   
                                                     field_names_arr, $
                                                     SWAP_ENDIAN=swap_endian, $
                                                     DEBUG=debug
                               
                                                    
                    n_fields = N_elements(field_names_arr)
                    
                    for j = 0, total_elements-1 do begin
                    
                        for i = 0, n_fields-1 do begin
                            
                            IF keyword_set(debug) THEN BEGIN
                                print
                                print, '* Struct field name tag: ', $
                                       field_names_arr[i]
                            ENDIF
                            
                            field_element_tag = element_tag_struct()
                            
                            read_element_tag_memory, raw_data_in, $
                                                     mem_read_ptr, $
                                                     field_element_tag, $
                                                     SWAP_ENDIAN=swap_endian, $
                                                     DEBUG=debug
                            
                            IF keyword_set(debug) THEN BEGIN
                                print
                                print, '* Struct field name data: ', $
                                       field_names_arr[i]
                            ENDIF
                            
                            field_data = read_mat_element_memory(field_element_tag,$
                                                        raw_data_in, $
                                                        mem_read_ptr, $
                                                        output_var_name, $
                                                        SWAP_ENDIAN=swap_endian, $
                                                        DEBUG=debug)
                            
                            ; build the structure
                            
                            if i eq 0 then begin
                                
                                tmp_struct = create_struct(field_names_arr[i], $
                                                           field_data)
                                
                            endif else begin
                                
                                tmp_struct = create_struct(tmp_struct, $
                                                           field_names_arr[i], $
                                                           field_data)
                                
                            endelse
                            
                        endfor
                        
                        ; build the structure array 
                        
                        if j eq 0 then begin
                            
                            tmp_str_array = replicate(tmp_struct, $
                                                      total_elements)
                                
                        endif else begin
                            
                            tmp_str_array[j] = tmp_struct
                            
                        endelse
                        
                    endfor
                    
                    ; reform the structure array to have the correct dimensions,
                    ; and prevent 1x1 arrays from being created
                    
                    if size(tmp_str_array, /N_ELEMENTS) eq 1 then begin
                        
                        data_out = tmp_str_array[0]
                        
                    endif else begin
                        
                        data_out = reform(reform(tmp_str_array, $
                                                 out_dims, $
                                                 /overwrite))
                        
                    endelse
                    
                end
                
                
                'mxOBJECT_CLASS': begin
                    
                    message, 'Object data is type not supported'            
                    
                end
                
                'mxSPARSE_CLASS': begin

                    message, 'Sparse array data type is not supported'                    

                end
                
                else: begin
                   
                    ; numeric or character array 
                    
                    ;; Real part (pr) subelement
        
                    IF keyword_set(debug) THEN BEGIN
                        print
                        print, '* Real part subelement tag'
                    ENDIF
        
                    real_part_tag = element_tag_struct()
                    
                    read_element_tag_memory, raw_data_in, $
                                             mem_read_ptr, $
                                             real_part_tag, $
                                             SWAP_ENDIAN=swap_endian, $
                                             DEBUG=debug
        
                    IF keyword_set(debug) THEN BEGIN
                        print
                        print, '* Real part subelement data'
                    ENDIF
        
                    real_data = read_mat_element_memory(real_part_tag, $
                                                    raw_data_in, $
                                                    mem_read_ptr, $
                                                    output_var_name, $
                                                    SWAP_ENDIAN=swap_endian, $
                                                    DEBUG=debug)

                    ; cast the data to its matlab type
                    
                    tmp_dat = cast_to_matrix_type(real_data,matrix_class)
        
                    IF chk_complex THEN BEGIN
        
                        ;; Imaginary part (pi) subelement
        
                        IF keyword_set(debug) THEN BEGIN
                            print
                            print, '* Imaginary part subelement tag'
                        ENDIF
        
                        imag_part_tag = element_tag_struct()
                        
                        read_element_tag_memory, raw_data_in, $
                                                 mem_read_ptr, $
                                                 imag_part_tag, $
                                                 SWAP_ENDIAN=swap_endian, $
                                                 DEBUG=debug
        
                        IF keyword_set(debug) THEN BEGIN
                            print
                            print, '* Imaginary part subelement data'
                        ENDIF
        
                        imag_data = read_mat_element_memory(imag_part_tag, $
                                                    raw_data_in, $
                                                    mem_read_ptr, $
                                                    output_var_name, $
                                                    SWAP_ENDIAN=swap_endian, $
                                                    DEBUG=debug)
        
                        tmp_idat = cast_to_matrix_type(real_data,matrix_class)
        
                        if matrix_class eq 'mxDOUBLE_CLASS' then begin
                            
                            chk_dcomplex = 1
                            
                        endif else begin
                            
                            chk_dcomplex = 0
                            
                        endelse
        
                        tmp_dat = complex(temporary(tmp_dat), $
                                          temporary(tmp_idat), $
                                          DOUBLE=chk_dcomplex)
        
                    ENDIF
        

                    ; prevent 1x1 arrays from being created
                    
                    if size(tmp_dat, /N_ELEMENTS) eq 1 then begin
                        
                        data_out = tmp_dat[0]
                        
                    endif else begin
                        
                        data_out = reform(reform(tmp_dat, out_dims, /overwrite))
                        
                    endelse
        
                end
                
            endcase

            output_var_name = array_name
            
            break
        END



        'miCOMPRESSED': begin
            
            message, 'Encountered miCOMPRESSED data in memory stream'
            
            break 
        end

    ENDSWITCH


    return, data_out


END


PRO wmb_load_mat, file, STORE_LEVEL=store_level, $
                  VERBOSE=verbose, DEBUG=debug

    header = { mat_v5_header, $
               description: "", $
               subsys_data_offset: 0ULL, $
               version: 0U, $
               endian_indicator: "" $
             }


    file_information = file_info(file)

    IF file_information.exists EQ 0 THEN BEGIN
        print, "File does not exist (", file, ")"
        return
    ENDIF

    IF file_information.directory EQ 1 THEN BEGIN
        print, "File is a directory (", file, ")"
        return
    ENDIF

    openr, lun, file, /GET_LUN

    ;; By default, create the variables on the $MAIN$ level

    IF NOT keyword_set(store_level) THEN store_level = 1

    IF keyword_set(debug) THEN BEGIN
        print
        print, '* Header'
    ENDIF

    ;; Todo: put this header code into a procedure

    description = bytarr(116)
    subsys_data_offset = 0ULL
    version = 0U
    endian_indicator = 0

    readu, lun, description
    readu, lun, subsys_data_offset
    readu, lun, version
    readu, lun, endian_indicator

    header.description = string(description)
    header.subsys_data_offset = subsys_data_offset
    header.version = version
    header.endian_indicator = $
        string(byte(ISHFT(endian_indicator AND 'FF00'XS, -8))) + $
        string(byte(endian_indicator AND '00FF'XS))

    IF keyword_set(DEBUG) THEN BEGIN
        print, 'Description           : ', header.description
        print, 'Subsystem data offset : ', $
               header.subsys_data_offset, FORMAT='(A,Z016)'
        print, 'Header version        : ', header.version, FORMAT='(A,Z04)'
        print, 'Endian                : ', header.endian_indicator
    ENDIF

    ;; Figure out whether we need to do endian swapping
    swap_endian = (header.endian_indicator EQ 'IM' ? 1 : 0)

    data = 0
    data_element_number = 0

    WHILE NOT(eof(lun)) DO BEGIN

        IF keyword_set(debug) THEN BEGIN
            print, '=========================================================='
            print, '* Data Element ', data_element_number++
        ENDIF

        element_tag = element_tag_struct()
        
        IF keyword_set(debug) THEN BEGIN
            point_lun, -lun, current_file_position
            print, 'Current file position : ', current_file_position, $
                   FORMAT='(A, Z08)'
        ENDIF
        
        read_element_tag_disk, lun, $
                               element_tag, $
                               SWAP_ENDIAN=swap_endian, $
                               DEBUG=debug

        ; load the data element into memory - if the element is compressed, 
        ; we need to decompress it here
        
        data_symbol = element_tag.data_symbol
        
        if data_symbol eq 'miCOMPRESSED' then begin
        
            ; we need to read in the data and uncompress it in memory
        
            data_size_bytes = element_tag.number_of_bytes
        
            data_element_comp = bytarr(data_size_bytes, /NOZERO)
        
            readu, lun, data_element_comp
            
            ; compressed data elements are not aligned to the 64-bit 
            ; boundaries, so we don't need to skip padding bytes here
        
            data_element_uncomp = ZLIB_UNCOMPRESS(data_element_comp, TYPE = 1)
            
            mem_read_ptr = 0UL
            
            ; read the new element tag (this cannot be miCOMPRESSED)
            
            read_element_tag_memory, data_element_uncomp, $
                                     mem_read_ptr, $
                                     element_tag, $
                                     SWAP_ENDIAN=swap_endian, $
                                     DEBUG=debug
            
            data_symbol = element_tag.data_symbol
            
            data_element_raw = temporary(data_element_uncomp[mem_read_ptr:-1])
            
        endif else begin
            
            data_size_bytes = element_tag.number_of_bytes
            data_element_raw = bytarr(data_size_bytes, /NOZERO)
            readu, lun, data_element_raw
            skip_padding_bytes_disk, lun, DEBUG=debug            
            
        endelse

        ; we now have the entire data element loaded into memory as a 
        ; byte array

        data_out = read_mat_element_memory(element_tag, $
                                           data_element_raw, $
                                           0UL, $)
                                           output_var_name, $
                                           SWAP_ENDIAN=swap_endian, $
                                           DEBUG=debug)


        ;; Create a variable on the main level using the undocumented
        ;; IDL routine ROUTINE_NAMES. 

        foo = routine_names(output_var_name, data_out, STORE=store_level)

        IF keyword_set(debug) THEN BEGIN
            point_lun, -lun, current_file_position
            print, 'Current file position : ', current_file_position, $
                   FORMAT='(A, Z08)'
        ENDIF

    ENDWHILE

    close, lun
    free_lun, lun

END
