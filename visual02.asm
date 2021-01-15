; *******************************************************************
; *** This software is copyright 2004 by Michael H Riley          ***
; *** You have permission to use, modify, copy, and distribute    ***
; *** this software so long as this copyright notice is retained. ***
; *** This software may not be used in commercial applications    ***
; *** without express written permission from the author.         ***
; *******************************************************************

include    bios.inc
include    kernel.inc

#define V2 0e000h
#define V2DATA 07f00h

org:       equ     7c00h

           org     8000h
           lbr     0ff00h
           db      'visual02',0
           dw      0c000h
           dw      endrom+0c000h-org
           dw      7c00h
           dw      endrom-org
           dw      7c00h
           db      0

           org     7c00h
           br      start

include    date.inc
include    build.inc
           db      'Written by Michael H. Riley',0

start:     mov     rf,0e020h           ; need to check signature
           lda     rf                  ; looking for 0,ADC,0
           lbnz    bad                 ; if any portion is missing, error
           lda     rf
           smi     'A'
           lbnz    bad
           lda     rf
           smi     'D'
           lbnz    bad
           lda     rf
           smi     'C'
           lbnz    bad
           lda     rf
           smi     ' '
           lbnz    bad
           lda     rf
           lbz     go
bad:       sep     scall               ; Visual/02 not present, display error
           dw      o_inmsg
           db      'Visual/02 is not present in ROM.  Aborting.',10,13,0
           lbr     o_wrmboot
go:        ldn     ra                  ; see if argument provided
           lbz     V2+3                ; jump immediately to visual/02 if none
           ghi     ra                  ; copy argument address to rf
           phi     rf
           glo     ra
           plo     rf
loop1:     lda     rf                  ; look for first less <= space
           smi     33
           bdf     loop1
           dec     rf                  ; backup to char
           ldi     0                   ; need proper termination
           str     rf
           ghi     ra                  ; back to beginning of name
           phi     rf
           glo     ra
           plo     rf
           ldi     high fildes         ; get file descriptor
           phi     rd
           ldi     low fildes
           plo     rd
           ldi     0                   ; flags for open
           plo     r7
           sep     scall               ; attempt to open file
           dw      o_open
           bnf     opened              ; jump if file was opened
           ldi     high errmsg         ; get error message
           phi     rf
           ldi     low errmsg
           plo     rf
           sep     scall               ; display it
           dw      o_msg
           lbr     o_wrmboot           ; and return to os
opened:    ldi     high buffer         ; buffer to rettrieve data
           phi     rf
           ldi     low buffer
           plo     rf
           ldi     0                   ; need to read 6 byte header
           phi     rc
           ldi     6
           plo     rc
           sep     scall               ; read the header
           dw      o_read
           ldi     high buffer         ; point to header
           phi     r9
           ldi     low buffer
           plo     r9
           lda     r9                  ; get load address
           phi     rf
           lda     r9
           plo     rf
           lda     r9                  ; get size
           phi     rc
           lda     r9
           plo     rc
           lda     r9                  ; get start address
           phi     r7
           lda     r9
           plo     r9
           ldi     V2DATA.1
           phi     r8
           ldi     6
           plo     r8 
           ghi     r7                  ; write start address to R3
           str     r8
           inc     r8
           glo     r7
           str     r8
           sep     scall               ; read rest of file
           dw      o_read
           sep     scall               ; close the file
           dw      o_close
           ldi     V2DATA.1
           phi     r8
           ldi     4                   ; point to R2
           plo     r8
           ghi     r2                  ; copy stack pointer
           str     r8
           inc     r8
           glo     r2
           str     r8
           ldi     3                   ; P=3
           plo     r9
           ldi     2                   ; X=2
           phi     r9
           lbr     V2+3                ; jump to Visual/02

errmsg:    db      'File not found',10,13,0
fildes:    db      0,0,0,0
           dw      dta
           db      0,0
           db      0
           db      0,0,0,0
           dw      0,0
           db      0,0,0,0

endrom:    equ     $

buffer:    ds      10
outbuf:    dw      80

dta:       ds      512

