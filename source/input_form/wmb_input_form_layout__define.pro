;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_input_form_layout__define:
;
;        This structure is used to define the layout of 
;        form widgets created using wmb_input_form
;
;cccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc

pro wmb_input_form_layout__define

    struct = { wmb_input_form_layout,                 $
               page_title       : '',                 $
               description      : '',                 $
               n_columns        : 0,                  $
               widget_key_list  : list()              }
               
end