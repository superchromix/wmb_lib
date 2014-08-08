;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc
;
;   wmb_find_tlb
;
;   Adapted from a snippet of code by David Fanning
;
;ccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccccc


function wmb_find_tlb, widget_id

    parent = widget_id
   
    WHILE Widget_Info(parent, /Parent) NE 0 DO begin
    
        parent = Widget_Info(parent, /Parent) 

    endwhile

    return, parent
    
end
