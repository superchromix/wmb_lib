;+
; NAME:
;    PNGINTERP
;
; PURPOSE:
;    Interpolates between two grayscale .PNG images.
;
; CATEGORY:
;    Misc
;
; CALLING SEQUENCE:
;    PNGINTERP, Png1, Png2, Times, Outnames
;
; INPUTS:
;    Png1:     String containing the name of the first (t=0) image.
;
;    Png2:     String containing the name of the second (t=1) image.
;
;    Times:    One or more times at which to write interpolated images.
;              These may outside the range 0 to 1 as long as this does
;              not cause a byte overflow.
;
;    Outnames: An array of file names to write the output images to.
;              Must be the same length as Times.
;
; EXAMPLE:
;    PNGINTERP, 'file0.png', 'file1.png', [0.25,0.5,0.75],
;      ['file025.png', 'file05.png', 'file075.png']
;
; MODIFICATION HISTORY:
;    Written by:    Jeremy Bailin
;    12 June 2008   Public release in JBIU
;-
pro pnginterp, png1, png2, times, outnames

image1 = read_png(png1)
image2 = read_png(png2)

nt = n_elements(times)
for i=0l,nt-1 do begin
  imageinterp = times[i]*image2 + (1.-times[i])*image1
  write_png, outnames[i], imageinterp
endfor

end


