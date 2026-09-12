	.section	.text,"ax",@progbits
	.assume	ADL = 1
	.file	"llvm-link"
	.section	.text._celink_init,"ax",@progbits
	.globl	_celink_init                    ; -- Begin function celink_init
	.type	_celink_init,@function
_celink_init:                           ; @celink_init
; %bb.0:
	ld	de, 0
	xor	a, a
	ld	l, a
	ld	iy, _celink_usb_event
	ld	bc, 36106
	ld	(_connected_device), de
	ld	(_usb_initialized), a
	ld	(_serial_open), a
	ld	(_last_error), de
	ld	a, l
	ld	(_srl_buffer), a
	push	bc
	push	de
	push	de
	push	iy
	call	_usb_Init
	ex	de, hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB0_2
; %bb.1:
	ld	a, 1
	ld	(_usb_initialized), a
	ret
	.local	.LBB0_2
.LBB0_2:
	ld	(_last_error), de
	ret
	.local	.Lfunc_end0
.Lfunc_end0:
	.size	_celink_init, .Lfunc_end0-_celink_init
                                        ; -- End function
	.section	.text._celink_usb_event,"ax",@progbits
	.type	_celink_usb_event,@function     ; -- Begin function celink_usb_event
_celink_usb_event:                      ; @celink_usb_event
; %bb.0:
	call	__frameset0
	ld	iy, (ix + 6)
	ld	de, 0
	ld	bc, 1
	lea	hl, iy + 0
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB1_6
; %bb.1:
	ld	a, (_serial_open)
	ld	iy, (_connected_device)
	bit	0, a
	jr	z, .LBB1_4
; %bb.2:
	lea	hl, iy + 0
	ld	bc, (ix + 9)
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB1_4
; %bb.3:
	ld	hl, _srl_dev
	push	hl
	call	_srl_Close
	ld	de, 0
	pop	hl
	xor	a, a
	ld	(_serial_open), a
	ld	iy, (_connected_device)
	.local	.LBB1_4
.LBB1_4:
	lea	hl, iy + 0
	ld	bc, (ix + 9)
	or	a, a
	sbc	hl, bc
	jp	nz, .LBB1_16
; %bb.5:
	push	bc
	call	_usb_UnrefDevice
	ld	de, 0
	pop	hl
	ld	(_connected_device), de
	jp	.LBB1_16
	.local	.LBB1_6
.LBB1_6:
	ld	bc, 2
	lea	hl, iy + 0
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB1_9
; %bb.7:
	call	_usb_GetRole
	ld	a, l
	bit	4, a
	jr	nz, .LBB1_15
; %bb.8:
	ld	hl, (ix + 9)
	push	hl
	call	_usb_RefDevice
	pop	hl
	ld	hl, (ix + 9)
	ld	(_connected_device), hl
	push	hl
	call	_usb_ResetDevice
	pop	hl
	jr	.LBB1_15
	.local	.LBB1_9
.LBB1_9:
	ld	bc, 4
	lea	hl, iy + 0
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB1_13
; %bb.10:
	call	_usb_GetRole
	ld	a, l
	bit	4, a
	jr	nz, .LBB1_15
; %bb.11:
	ld	hl, _srl_buffer
	ld	de, 512
	ld	bc, 115200
	push	bc
	ld	bc, 255
	push	bc
	push	de
	push	hl
	ld	hl, (ix + 9)
	push	hl
	ld	hl, _srl_dev
	push	hl
	call	_srl_Open
	ex	de, hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB1_14
; %bb.12:
	ld	a, 1
	ld	(_serial_open), a
	jr	.LBB1_15
	.local	.LBB1_13
.LBB1_13:
	ld	hl, (ix + 12)
	push	hl
	ld	hl, (ix + 9)
	push	hl
	push	iy
	call	_srl_UsbEventCallback
	ex	de, hl
	pop	hl
	pop	hl
	pop	hl
	jr	.LBB1_16
	.local	.LBB1_14
.LBB1_14:
	ld	(_last_error), de
	.local	.LBB1_15
.LBB1_15:
	ld	de, 0
	.local	.LBB1_16
.LBB1_16:
	ex	de, hl
	pop	ix
	ret
	.local	.Lfunc_end1
.Lfunc_end1:
	.size	_celink_usb_event, .Lfunc_end1-_celink_usb_event
                                        ; -- End function
	.section	.text._celink_process,"ax",@progbits
	.globl	_celink_process                 ; -- Begin function celink_process
	.type	_celink_process,@function
_celink_process:                        ; @celink_process
; %bb.0:
	ld	a, (_usb_initialized)
	bit	0, a
	call	nz, _usb_HandleEvents
	ret
	.local	.Lfunc_end2
.Lfunc_end2:
	.size	_celink_process, .Lfunc_end2-_celink_process
                                        ; -- End function
	.section	.text._celink_connected,"ax",@progbits
	.globl	_celink_connected               ; -- Begin function celink_connected
	.type	_celink_connected,@function
_celink_connected:                      ; @celink_connected
; %bb.0:
	ld	a, (_serial_open)
	ret
	.local	.Lfunc_end3
.Lfunc_end3:
	.size	_celink_connected, .Lfunc_end3-_celink_connected
                                        ; -- End function
	.section	.text._celink_send,"ax",@progbits
	.globl	_celink_send                    ; -- Begin function celink_send
	.type	_celink_send,@function
_celink_send:                           ; @celink_send
; %bb.0:
	ld	hl, -3
	call	__frameset
	ld	bc, (ix + 6)
	ld	e, 0
	ld	a, (_serial_open)
	sbc	hl, hl
	adc	hl, bc
	jr	z, .LBB4_7
; %bb.1:
	bit	0, a
	jr	z, .LBB4_7
; %bb.2:
	push	bc
	call	_strlen
	ex	de, hl
	pop	hl
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB4_6
; %bb.3:
	ld	hl, _srl_dev
	ld	(ix - 3), de
	push	de
	ld	de, (ix + 6)
	push	de
	push	hl
	call	_srl_Write
	ex	de, hl
	pop	hl
	pop	hl
	pop	hl
	ld	bc, 0
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB4_5
; %bb.4:
	ld	(_last_error), de
	jr	.LBB4_6
	.local	.LBB4_5
.LBB4_5:
	ex	de, hl
	ld	de, (ix - 3)
	or	a, a
	sbc	hl, de
	jr	z, .LBB4_8
	.local	.LBB4_6
.LBB4_6:
	ld	e, 0
	.local	.LBB4_7
.LBB4_7:
	ld	a, e
	pop	hl
	pop	ix
	ret
	.local	.LBB4_8
.LBB4_8:
	ld	e, -1
	jr	.LBB4_7
	.local	.Lfunc_end4
.Lfunc_end4:
	.size	_celink_send, .Lfunc_end4-_celink_send
                                        ; -- End function
	.section	.text._celink_read,"ax",@progbits
	.globl	_celink_read                    ; -- Begin function celink_read
	.type	_celink_read,@function
_celink_read:                           ; @celink_read
; %bb.0:
	call	__frameset0
	ld	hl, (ix + 6)
	ld	bc, 0
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB5_7
; %bb.1:
	ld	de, (ix + 9)
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB5_7
; %bb.2:
	ld	a, (_serial_open)
	bit	0, a
	jr	z, .LBB5_6
; %bb.3:
	ld	hl, _srl_dev
	dec	de
	push	de
	ld	de, (ix + 6)
	push	de
	push	hl
	call	_srl_Read
	ex	de, hl
	pop	hl
	pop	hl
	pop	hl
	ld	bc, 0
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	call	pe, __setflag
	jp	p, .LBB5_5
; %bb.4:
	ld	(_last_error), de
	ld	bc, 0
	jr	.LBB5_6
	.local	.LBB5_5
.LBB5_5:
	push	de
	pop	bc
	.local	.LBB5_6
.LBB5_6:
	ld	hl, (ix + 6)
	add	hl, bc
	ld	(hl), 0
	.local	.LBB5_7
.LBB5_7:
	push	bc
	pop	hl
	pop	ix
	ret
	.local	.Lfunc_end5
.Lfunc_end5:
	.size	_celink_read, .Lfunc_end5-_celink_read
                                        ; -- End function
	.section	.text._celink_request,"ax",@progbits
	.globl	_celink_request                 ; -- Begin function celink_request
	.type	_celink_request,@function
_celink_request:                        ; @celink_request
; %bb.0:
	ld	hl, -79
	call	__frameset
	ld	hl, (ix + 12)
	xor	a, a
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB6_17
; %bb.1:
	ld	hl, (ix + 15)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB6_17
; %bb.2:
	ld	hl, (ix + 12)
	ld	(hl), 0
	call	_celink_drain_stale
	ld	hl, (ix + 6)
	push	hl
	call	_celink_send
	pop	hl
	bit	0, a
	jp	z, .LBB6_12
; %bb.3:                                ; %.preheader7.preheader
	ld	bc, (ix + 18)
	ld	de, 0
	lea	hl, ix - 64
	ld	(ix - 70), hl
	push	de
	pop	iy
	.local	.LBB6_4
.LBB6_4:                                ; %.preheader7
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB6_8 Depth 2
	lea	hl, iy + 0
	or	a, a
	sbc	hl, bc
	jp	nc, .LBB6_13
; %bb.5:                                ;   in Loop: Header=BB6_4 Depth=1
	ld	(ix - 76), iy
	ld	(ix - 67), de
	call	_celink_process
	ld	hl, 64
	push	hl
	ld	hl, (ix - 70)
	push	hl
	call	_celink_read
	ex	de, hl
	pop	hl
	pop	hl
	ld	(ix - 73), de
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB6_7
; %bb.6:                                ;   in Loop: Header=BB6_4 Depth=1
	ld	iy, (ix - 76)
	inc	iy
	ld	de, (ix - 67)
	ld	bc, (ix + 18)
	jr	.LBB6_4
	.local	.LBB6_7
.LBB6_7:                                ; %.preheader.preheader
                                        ;   in Loop: Header=BB6_4 Depth=1
	ld	hl, (ix + 12)
	ld	de, (ix - 67)
	add	hl, de
	ld	(ix - 79), hl
	ld	bc, 0
	.local	.LBB6_8
.LBB6_8:                                ; %.preheader
                                        ;   Parent Loop BB6_4 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	push	de
	pop	iy
	add	iy, bc
	ld	(ix - 76), bc
	push	bc
	pop	hl
	ld	bc, (ix - 73)
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB6_11
; %bb.9:                                ; %.preheader
                                        ;   in Loop: Header=BB6_8 Depth=2
	inc	iy
	lea	hl, iy + 0
	ld	de, (ix + 15)
	or	a, a
	sbc	hl, de
	ld	de, (ix - 67)
	jr	nc, .LBB6_11
; %bb.10:                               ;   in Loop: Header=BB6_8 Depth=2
	ld	hl, (ix - 70)
	ld	bc, (ix - 76)
	add	hl, bc
	ld	a, (hl)
	ld	hl, (ix - 79)
	add	hl, bc
	ld	(hl), a
	inc	bc
	jr	.LBB6_8
	.local	.LBB6_11
.LBB6_11:                               ; %.loopexit.loopexit
                                        ;   in Loop: Header=BB6_4 Depth=1
	ex	de, hl
	ld	de, (ix - 76)
	add	hl, de
	ld	iy, 0
	ex	de, hl
	ld	bc, (ix + 18)
	jp	.LBB6_4
	.local	.LBB6_12
.LBB6_12:
	xor	a, a
	jr	.LBB6_17
	.local	.LBB6_13
.LBB6_13:
	ld	iy, (ix + 12)
	lea	hl, iy + 0
	add	hl, de
	ld	(hl), 0
	push	de
	pop	bc
	sbc	hl, hl
	adc	hl, de
	ld	a, 0
	ld	de, (ix + 15)
	jr	z, .LBB6_17
; %bb.14:
	ld	a, (iy)
	ld	hl, (ix + 9)
	cp	a, l
	jr	nz, .LBB6_16
; %bb.15:
	lea	de, iy + 0
	push	de
	pop	hl
	inc	hl
	push	bc
	push	hl
	push	de
	call	_memmove
	pop	hl
	pop	hl
	pop	hl
	ld	a, 1
	jr	.LBB6_17
	.local	.LBB6_16
.LBB6_16:
	push	hl
	pop	bc
	or	a, a
	sbc	hl, hl
	ld	l, a
	push	bc
	push	hl
	ld	hl, _.str
	push	hl
	push	de
	push	iy
	call	_snprintf
	xor	a, a
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB6_17
.LBB6_17:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end6
.Lfunc_end6:
	.size	_celink_request, .Lfunc_end6-_celink_request
                                        ; -- End function
	.section	.text._celink_drain_stale,"ax",@progbits
	.type	_celink_drain_stale,@function   ; -- Begin function celink_drain_stale
_celink_drain_stale:                    ; @celink_drain_stale
; %bb.0:
	ld	hl, -67
	call	__frameset
	.local	.LBB7_1
.LBB7_1:                                ; %select.unfold
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB7_2 Depth 2
	ld	bc, 0
	.local	.LBB7_2
.LBB7_2:                                ; %select.unfold
                                        ;   Parent Loop BB7_1 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	de, 300
	push	bc
	pop	hl
	or	a, a
	sbc	hl, de
	jr	nc, .LBB7_5
; %bb.3:                                ; %select.unfold.backedge
                                        ;   in Loop: Header=BB7_2 Depth=2
	ld	(ix - 67), bc
	call	_celink_process
	ld	hl, 64
	push	hl
	pea	ix - 64
	call	_celink_read
	pop	de
	pop	de
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB7_1
; %bb.4:                                ;   in Loop: Header=BB7_2 Depth=2
	ld	bc, (ix - 67)
	inc	bc
	jr	.LBB7_2
	.local	.LBB7_5
.LBB7_5:
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end7
.Lfunc_end7:
	.size	_celink_drain_stale, .Lfunc_end7-_celink_drain_stale
                                        ; -- End function
	.section	.text._celink_last_error,"ax",@progbits
	.globl	_celink_last_error              ; -- Begin function celink_last_error
	.type	_celink_last_error,@function
_celink_last_error:                     ; @celink_last_error
; %bb.0:
	ld	hl, (_last_error)
	ret
	.local	.Lfunc_end8
.Lfunc_end8:
	.size	_celink_last_error, .Lfunc_end8-_celink_last_error
                                        ; -- End function
	.section	.text._celink_get,"ax",@progbits
	.globl	_celink_get                     ; -- Begin function celink_get
	.type	_celink_get,@function
_celink_get:                            ; @celink_get
; %bb.0:
	ld	hl, -810
	call	__frameset
	ld	hl, (ix + 15)
	ld	de, -1
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB9_2
; %bb.1:
	ld	hl, (ix + 15)
	ld	(hl), de
	.local	.LBB9_2
.LBB9_2:
	ld	e, 0
	ld	hl, (ix + 9)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB9_35
; %bb.3:
	ld	bc, (ix + 12)
	sbc	hl, hl
	adc	hl, bc
	jp	z, .LBB9_35
; %bb.4:
	push	bc
	pop	iy
	ld	bc, (ix + 6)
	ld	hl, (ix + 9)
	ld	(hl), 0
	sbc	hl, hl
	adc	hl, bc
	jp	z, .LBB9_35
; %bb.5:
	ld	a, (_serial_open)
	bit	0, a
	jp	z, .LBB9_35
; %bb.6:
	ld	de, _.str.1
	ld	bc, -518
	lea	hl, ix + 0
	add	hl, bc
	push	ix
	ld	bc, -777
	add	ix, bc
	ld	(ix + 0), hl
	pop	ix
	dec	iy
	push	ix
	ld	bc, -780
	add	ix, bc
	ld	(ix + 0), iy
	pop	ix
	push	iy
	ld	bc, (ix + 6)
	push	bc
	push	de
	ld	de, 512
	push	de
	push	hl
	call	_snprintf
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	call	_celink_drain_stale
	ld	de, -777
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_celink_send
	pop	hl
	bit	0, a
	jp	z, .LBB9_34
; %bb.7:                                ; %.preheader23.preheader
	ld	de, -646
	lea	iy, ix + 0
	add	iy, de
	ld	bc, -774
	lea	hl, ix + 0
	add	hl, bc
	ex	de, hl
	or	a, a
	sbc	hl, hl
	xor	a, a
	push	ix
	ld	bc, -792
	add	ix, bc
	ld	(ix + 0), iy
	pop	ix
	lea	bc, iy + 0
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 21
	ld	(iy + 0), bc
	push	de
	pop	iy
	lea	bc, iy + 64
	push	ix
	ld	de, -795
	add	ix, de
	ld	(ix + 0), bc
	pop	ix
	lea	iy, iy + 0
	push	hl
	pop	bc
	push	ix
	ld	de, -777
	add	ix, de
	ld	(ix + 0), hl
	pop	ix
	push	ix
	ld	de, -786
	add	ix, de
	ld	(ix + 0), hl
	pop	ix
	.local	.LBB9_8
.LBB9_8:                                ; %.preheader23
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB9_13 Depth 2
                                        ;     Child Loop BB9_20 Depth 2
	bit	0, a
	jp	nz, .LBB9_25
; %bb.9:                                ; %.preheader23
                                        ;   in Loop: Header=BB9_8 Depth=1
	push	bc
	pop	hl
	ld	de, (ix + 18)
	or	a, a
	sbc	hl, de
	jp	nc, .LBB9_25
; %bb.10:                               ;   in Loop: Header=BB9_8 Depth=1
	ld	de, -798
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), bc
	ld	de, -783
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	call	_celink_process
	ld	hl, 64
	push	hl
	ld	de, -783
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_celink_read
	ex	de, hl
	pop	hl
	pop	hl
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB9_12
; %bb.11:                               ;   in Loop: Header=BB9_8 Depth=1
	ld	de, -798
	lea	iy, ix + 0
	add	iy, de
	ld	bc, (iy + 0)
	inc	bc
	xor	a, a
	jp	.LBB9_24
	.local	.LBB9_12
.LBB9_12:                               ;   in Loop: Header=BB9_8 Depth=1
	ld	bc, 0
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 15
	ld	iy, (ix + 0)
	pop	ix
	.local	.LBB9_13
.LBB9_13:                               ; %.preheader22
                                        ;   Parent Loop BB9_8 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jp	z, .LBB9_18
; %bb.14:                               ;   in Loop: Header=BB9_13 Depth=2
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 30
	ld	(ix + 0), de
	pop	ix
	lea	hl, iy + 0
	push	bc
	pop	de
	add	hl, de
	ld	a, (hl)
	cp	a, 10
	ld	de, -801
	lea	hl, ix + 0
	push	af
	add	hl, de
	pop	af
	ld	(hl), bc
	jp	z, .LBB9_19
; %bb.15:                               ;   in Loop: Header=BB9_13 Depth=2
	ld	de, -777
	lea	hl, ix + 0
	add	hl, de
	ld	bc, (hl)
	inc	bc
	push	bc
	pop	hl
	ld	de, 128
	or	a, a
	sbc	hl, de
	jr	nc, .LBB9_17
; %bb.16:                               ;   in Loop: Header=BB9_13 Depth=2
	ld	de, -789
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 9
	ld	de, (ix + 0)
	pop	ix
	add	iy, de
	ld	(iy), a
	ld	de, -783
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	ld	de, -777
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), bc
	.local	.LBB9_17
.LBB9_17:                               ;   in Loop: Header=BB9_13 Depth=2
	ld	bc, -798
	lea	hl, ix + 0
	add	hl, bc
	ld	de, (hl)
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 33
	ld	bc, (ix + 0)
	pop	ix
	inc	bc
	jp	.LBB9_13
	.local	.LBB9_18
.LBB9_18:                               ;   in Loop: Header=BB9_8 Depth=1
	ld	de, -789
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	ld	bc, -777
	lea	hl, ix + 0
	add	hl, bc
	ld	de, (hl)
	add	iy, de
	ld	(iy), 0
	ld	de, -783
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	ld	bc, 0
	xor	a, a
	jp	.LBB9_8
	.local	.LBB9_19
.LBB9_19:                               ;   in Loop: Header=BB9_8 Depth=1
	ld	de, -789
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 9
	ld	de, (ix + 0)
	pop	ix
	add	iy, de
	ld	(iy), 0
	ld	de, -795
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 18
	ld	de, (iy + 0)
	add	hl, de
	ld	de, -807
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	de, -783
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	bc
	pop	de
	add	hl, de
	ld	de, -810
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	de, 0
	.local	.LBB9_20
.LBB9_20:                               ;   Parent Loop BB9_8 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 18
	ld	iy, (ix + 0)
	pop	ix
	add	iy, de
	push	bc
	pop	hl
	push	ix
	ld	bc, -804
	add	ix, bc
	ld	(ix + 0), de
	pop	ix
	add	hl, de
	inc	hl
	push	ix
	ld	bc, -798
	add	ix, bc
	ld	de, (ix + 0)
	pop	ix
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB9_23
; %bb.21:                               ;   in Loop: Header=BB9_20 Depth=2
	lea	hl, iy + 0
	ld	bc, 64
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB9_23
; %bb.22:                               ;   in Loop: Header=BB9_20 Depth=2
	ld	de, -810
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	ld	bc, -804
	lea	hl, ix + 0
	add	hl, bc
	ld	de, (hl)
	add	iy, de
	ld	a, (iy + 1)
	ld	bc, -807
	lea	iy, ix + 0
	add	iy, bc
	ld	hl, (iy + 0)
	add	hl, de
	ld	(hl), a
	inc	de
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 33
	ld	bc, (iy + 0)
	jp	.LBB9_20
	.local	.LBB9_23
.LBB9_23:                               ; %.loopexit21.loopexit
                                        ;   in Loop: Header=BB9_8 Depth=1
	ld	de, -786
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	bc, -804
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	add	hl, de
	ld	bc, 0
	ld	a, 1
	ld	de, -786
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	.local	.LBB9_24
.LBB9_24:                               ; %.preheader23
                                        ;   in Loop: Header=BB9_8 Depth=1
	ld	de, -783
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	jp	.LBB9_8
	.local	.LBB9_25
.LBB9_25:
	bit	0, a
	jr	z, .LBB9_31
; %bb.26:
	ld	de, -783
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	ld	de, -792
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	ld	a, (iy + 0)
	ld	bc, -777
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	sbc	hl, hl
	adc	hl, de
	ld	bc, (ix + 12)
	jr	z, .LBB9_28
; %bb.27:
	cp	a, 4
	jr	z, .LBB9_36
	.local	.LBB9_28
.LBB9_28:
	ex	de, hl
	ld	de, 0
	add	hl, bc
	or	a, a
	sbc	hl, bc
	ld	hl, -1
	jr	z, .LBB9_30
; %bb.29:
	ld	e, a
	ex	de, hl
	.local	.LBB9_30
.LBB9_30:
	push	hl
	ld	hl, _.str.3
	push	hl
	push	bc
	ld	hl, (ix + 9)
	push	hl
	call	_snprintf
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	jr	.LBB9_34
	.local	.LBB9_31
.LBB9_31:
	ld	de, -780
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, _.str.2
	.local	.LBB9_32
.LBB9_32:
	push	hl
	.local	.LBB9_33
.LBB9_33:
	ld	hl, (ix + 9)
	push	hl
	call	_strncpy
	pop	hl
	pop	hl
	pop	hl
	ld	iy, (ix + 9)
	ld	de, (ix + 12)
	add	iy, de
	ld	(iy - 1), 0
	.local	.LBB9_34
.LBB9_34:
	ld	e, 0
	.local	.LBB9_35
.LBB9_35:
	ld	a, e
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB9_36
.LBB9_36:
	ld	bc, -789
	lea	iy, ix + 0
	add	iy, bc
	ld	hl, (iy + 0)
	push	hl
	pop	iy
	inc	iy
	push	de
	push	iy
	push	hl
	call	_memmove
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 6
	push	hl
	ld	hl, _.str.4
	push	hl
	ld	de, -789
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_memcmp
	pop	de
	pop	de
	pop	de
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB9_38
; %bb.37:
	ld	de, -780
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	de, -789
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	pea	iy + 6
	jr	.LBB9_33
	.local	.LBB9_38
.LBB9_38:
	ld	hl, 124
	push	hl
	ld	de, -789
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_strchr
	ex	de, hl
	pop	hl
	pop	hl
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB9_40
; %bb.39:
	inc	de
	ld	bc, -777
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), de
	ld	hl, 124
	push	hl
	push	de
	call	_strchr
	ld	bc, -777
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	push	hl
	pop	bc
	pop	hl
	pop	hl
	sbc	hl, hl
	adc	hl, bc
	jr	nz, .LBB9_41
	.local	.LBB9_40
.LBB9_40:
	ld	de, -780
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, _.str.5
	jp	.LBB9_32
	.local	.LBB9_41
.LBB9_41:
	ld	hl, (ix + 15)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB9_43
; %bb.42:
	push	de
	ld	de, -777
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), bc
	call	_atoi
	ld	de, -777
	lea	iy, ix + 0
	add	iy, de
	ld	bc, (iy + 0)
	pop	de
	ld	iy, (ix + 15)
	ld	(iy), hl
	.local	.LBB9_43
.LBB9_43:
	inc	bc
	push	bc
	call	_atol
	push	hl
	pop	iy
	ld	a, e
	pop	hl
	lea	hl, iy + 0
	call	__lcmpzero
	jp	p, .LBB9_45
; %bb.44:
	ld	de, -780
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, _.str.6
	jp	.LBB9_32
	.local	.LBB9_45
.LBB9_45:
	ld	bc, 0
	ld	de, -792
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	ld	de, -789
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), a
	.local	.LBB9_46
.LBB9_46:                               ; %.preheader20
                                        ; =>This Inner Loop Header: Depth=1
	push	bc
	pop	hl
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 18
	ld	de, (ix + 0)
	pop	ix
	or	a, a
	sbc	hl, de
	jr	nc, .LBB9_49
; %bb.47:                               ; %.preheader20
                                        ;   in Loop: Header=BB9_46 Depth=1
	push	bc
	pop	iy
	push	bc
	pop	de
	inc	de
	push	de
	pop	hl
	ld	bc, (ix + 12)
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB9_50
; %bb.48:                               ;   in Loop: Header=BB9_46 Depth=1
	push	ix
	ld	bc, -795
	add	ix, bc
	ld	hl, (ix + 0)
	pop	ix
	lea	bc, iy + 0
	add	hl, bc
	ld	a, (hl)
	ld	hl, (ix + 9)
	add	hl, bc
	ld	(hl), a
	ld	bc, -789
	lea	iy, ix + 0
	add	iy, bc
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	push	de
	pop	bc
	ld	de, -792
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	jr	.LBB9_46
	.local	.LBB9_49
.LBB9_49:
	ld	de, 0
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 12
	ld	(ix + 0), de
	jp	.LBB9_59
	.local	.LBB9_50
.LBB9_50:
	ld	de, 0
	ld	bc, -780
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), de
	lea	bc, iy + 0
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 24
	ld	iy, (ix + 0)
	jp	.LBB9_59
	.local	.LBB9_51
.LBB9_51:                               ; %.preheader19
                                        ;   in Loop: Header=BB9_59 Depth=1
	push	ix
	ld	de, -780
	add	ix, de
	ld	hl, (ix + 0)
	pop	ix
	ld	de, (ix + 18)
	or	a, a
	sbc	hl, de
	jp	nc, .LBB9_60
; %bb.52:                               ;   in Loop: Header=BB9_59 Depth=1
	call	_celink_process
	ld	hl, 64
	push	hl
	ld	de, -783
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_celink_read
	ex	de, hl
	pop	hl
	pop	hl
	ld	bc, -786
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), de
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB9_54
; %bb.53:                               ;   in Loop: Header=BB9_59 Depth=1
	ld	de, -780
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	inc	hl
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	de, 0
	ld	bc, -792
	lea	hl, ix + 0
	add	hl, bc
	ld	iy, (hl)
	ld	bc, -789
	lea	hl, ix + 0
	add	hl, bc
	ld	a, (hl)                         ; 1-byte Folded Reload
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 9
	ld	bc, (ix + 0)
	jp	.LBB9_59
	.local	.LBB9_54
.LBB9_54:                               ; %.preheader.preheader
                                        ;   in Loop: Header=BB9_59 Depth=1
	ld	hl, (ix + 9)
	ld	bc, -777
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	add	hl, de
	ld	de, -780
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	bc, 0
	.local	.LBB9_55
.LBB9_55:                               ; %.preheader
                                        ;   Parent Loop BB9_59 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	ld	de, -777
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	add	iy, bc
	push	bc
	pop	hl
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 18
	ld	de, (ix + 0)
	pop	ix
	or	a, a
	sbc	hl, de
	jr	nc, .LBB9_58
; %bb.56:                               ; %.preheader
                                        ;   in Loop: Header=BB9_55 Depth=2
	inc	iy
	lea	hl, iy + 0
	ld	de, (ix + 12)
	or	a, a
	sbc	hl, de
	jr	nc, .LBB9_58
; %bb.57:                               ;   in Loop: Header=BB9_55 Depth=2
	ld	de, -783
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	add	hl, bc
	ld	a, (hl)
	ld	de, -780
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	add	hl, bc
	ld	(hl), a
	inc	bc
	jr	.LBB9_55
	.local	.LBB9_58
.LBB9_58:                               ; %.loopexit.loopexit
                                        ;   in Loop: Header=BB9_59 Depth=1
	ld	de, -777
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	add	hl, bc
	ld	de, 0
	ld	bc, -780
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), de
	push	hl
	pop	bc
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 24
	ld	iy, (ix + 0)
	pop	ix
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 21
	ld	a, (ix + 0)                     ; 1-byte Folded Reload
	.local	.LBB9_59
.LBB9_59:                               ; %.preheader19
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB9_55 Depth 2
	pop	ix
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 9
	ld	(ix + 0), bc
	pop	ix
	push	bc
	pop	hl
	lea	bc, iy + 0
	call	__lcmps
	call	pe, __setflag
	jp	m, .LBB9_51
	.local	.LBB9_60
.LBB9_60:
	or	a, a
	sbc	hl, hl
	ld	e, l
	ld	hl, (ix + 9)
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 9
	ld	bc, (ix + 0)
	pop	ix
	add	hl, bc
	ld	(hl), 0
	push	bc
	pop	hl
	lea	bc, iy + 0
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 21
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	call	__lcmps
	call	pe, __setflag
	jp	p, .LBB9_62
; %bb.61:
	ld	e, 0
	jr	.LBB9_63
	.local	.LBB9_62
.LBB9_62:
	ld	e, 1
	.local	.LBB9_63
.LBB9_63:
	ld	bc, (ix + 12)
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 9
	ld	hl, (iy + 0)
	inc	hl
	or	a, a
	sbc	hl, bc
	ccf
                                        ; kill: def $a killed $a
	sbc	a, a
	ld	l, a
	ld	a, e
	or	a, l
	ld	e, a
	jp	.LBB9_35
	.local	.Lfunc_end9
.Lfunc_end9:
	.size	_celink_get, .Lfunc_end9-_celink_get
                                        ; -- End function
	.section	.text._celink_disconnect,"ax",@progbits
	.globl	_celink_disconnect              ; -- Begin function celink_disconnect
	.type	_celink_disconnect,@function
_celink_disconnect:                     ; @celink_disconnect
; %bb.0:
	ld	a, (_serial_open)
	bit	0, a
	jr	z, .LBB10_2
; %bb.1:
	ld	hl, _srl_dev
	push	hl
	call	_srl_Close
	pop	hl
	xor	a, a
	ld	(_serial_open), a
	.local	.LBB10_2
.LBB10_2:
	ld	de, (_connected_device)
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB10_4
; %bb.3:
	push	de
	call	_usb_UnrefDevice
	pop	hl
	or	a, a
	sbc	hl, hl
	ld	(_connected_device), hl
	.local	.LBB10_4
.LBB10_4:
	ld	a, (_usb_initialized)
	bit	0, a
	jr	z, .LBB10_6
; %bb.5:
	call	_usb_Cleanup
	xor	a, a
	ld	(_usb_initialized), a
	.local	.LBB10_6
.LBB10_6:
	ret
	.local	.Lfunc_end10
.Lfunc_end10:
	.size	_celink_disconnect, .Lfunc_end10-_celink_disconnect
                                        ; -- End function
	.section	.text._main,"ax",@progbits
	.globl	_main                           ; -- Begin function main
	.type	_main,@function
_main:                                  ; @main
; %bb.0:
	ld	hl, -668
	call	__frameset
	ld	de, -378
	lea	iy, ix + 0
	add	iy, de
	ld	bc, -634
	lea	hl, ix + 0
	add	hl, bc
	ex	de, hl
	xor	a, a
	dec	bc
	lea	hl, ix + 0
	add	hl, bc
	ld	(hl), a
	lea	hl, iy + 0
	lea	bc, iy + 0
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 16
	ld	(iy + 0), hl
	push	de
	pop	iy
	lea	hl, iy + 0
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 13
	ld	(iy + 0), hl
	lea	hl, ix - 70
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 4
	ld	(iy + 0), hl
	lea	hl, ix - 78
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 19
	ld	(iy + 0), hl
	push	bc
	pop	iy
	lea	hl, iy + 0
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 10
	ld	(iy + 0), hl
	push	de
	pop	iy
	ld	de, -662
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	lea	hl, iy + 0
	ld	de, -641
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	push	bc
	pop	iy
	ld	de, -647
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	lea	hl, iy + 0
	ld	de, -638
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	iy, -3145600
	call	_os_ClrLCD
	call	_os_HomeUp
	call	_os_DrawStatusBar
	call	_celink_init
	or	a, a
	sbc	hl, hl
	.local	.LBB11_1
.LBB11_1:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB11_2 Depth 2
                                        ;     Child Loop BB11_19 Depth 2
	push	hl
	call	_draw_menu
	pop	hl
	.local	.LBB11_2
.LBB11_2:                               ;   Parent Loop BB11_1 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	call	_kb_Scan
	call	_celink_process
	ld	a, (_serial_open)
	ld	c, a
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 123
	ld	e, (iy + 0)                     ; 1-byte Folded Reload
	ld	a, e
	xor	a, c
	ld	l, a
	bit	0, l
	jr	z, .LBB11_4
; %bb.3:                                ;   in Loop: Header=BB11_2 Depth=2
	ld	l, c
	push	hl
	ld	de, -635
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), c                     ; 1-byte Folded Spill
	call	_draw_menu
	pop	hl
	ld	bc, -635
	lea	iy, ix + 0
	add	iy, bc
	ld	e, (iy + 0)                     ; 1-byte Folded Reload
	.local	.LBB11_4
.LBB11_4:                               ;   in Loop: Header=BB11_2 Depth=2
	ld	hl, -720868
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, e
	ld	h, d
	pop	de
	ld	a, l
	bit	6, a
	jp	nz, .LBB11_61
; %bb.5:                                ;   in Loop: Header=BB11_2 Depth=2
	ld	iy, -720874
	ld	l, (iy)
	ld	h, (iy + 1)
	ld	a, l
	bit	1, a
	ld	bc, -635
	lea	hl, ix + 0
	push	af
	add	hl, bc
	pop	af
	ld	(hl), e
	jp	nz, .LBB11_16
; %bb.6:                                ;   in Loop: Header=BB11_2 Depth=2
	ld	hl, -720872
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, e
	ld	h, d
	pop	de
	ld	a, l
	bit	1, a
	jp	nz, .LBB11_24
; %bb.7:                                ;   in Loop: Header=BB11_2 Depth=2
	ld	hl, -720870
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, e
	ld	h, d
	pop	de
	ld	a, l
	bit	1, a
	jp	nz, .LBB11_30
; %bb.8:                                ;   in Loop: Header=BB11_2 Depth=2
	ld	l, (iy)
	ld	h, (iy + 1)
	ld	a, l
	bit	2, a
	jp	nz, .LBB11_38
; %bb.9:                                ;   in Loop: Header=BB11_2 Depth=2
	ld	hl, -720872
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, e
	ld	h, d
	pop	de
	ld	a, l
	bit	2, a
	jp	nz, .LBB11_43
; %bb.10:                               ;   in Loop: Header=BB11_2 Depth=2
	ld	hl, -720870
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, e
	ld	h, d
	pop	de
	ld	a, l
	bit	2, a
	jp	nz, .LBB11_48
; %bb.11:                               ;   in Loop: Header=BB11_2 Depth=2
	ld	l, (iy)
	ld	h, (iy + 1)
	ld	a, l
	bit	3, a
	jp	nz, .LBB11_55
; %bb.12:                               ;   in Loop: Header=BB11_2 Depth=2
	ld	l, (iy)
	ld	h, (iy + 1)
	ld.sis	bc, 1
	call	__sand
	bit	0, l
	jp	z, .LBB11_2
; %bb.13:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	hl, -3145600
	push	hl
	pop	iy
	call	_os_ClrLCD
	ld	iy, -3145600
	call	_os_HomeUp
	call	_os_DrawStatusBar
	ld	hl, _.str.38
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	call	_os_NewLine
	ld	a, (_serial_open)
	bit	0, a
	ld	hl, _.str.39
	jr	nz, .LBB11_15
; %bb.14:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	hl, _.str.40
	.local	.LBB11_15
.LBB11_15:                              ;   in Loop: Header=BB11_1 Depth=1
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	hl, -3145600
	push	hl
	pop	iy
	call	_os_NewLine
	ld	hl, (_last_error)
	push	hl
	ld	hl, _.str.41
	push	hl
	ld	de, -656
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_sprintf
	pop	hl
	pop	hl
	pop	hl
	ld	de, -656
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	jp	.LBB11_37
	.local	.LBB11_16
.LBB11_16:                              ;   in Loop: Header=BB11_1 Depth=1
	ld	a, (_serial_open)
	bit	0, a
	jp	z, .LBB11_28
; %bb.17:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	hl, 15000
	push	hl
	ld	hl, 256
	push	hl
	ld	de, -638
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, 1
	push	hl
	ld	hl, _.str.10
	push	hl
	call	_celink_request
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	bit	0, a
	jp	z, .LBB11_34
; %bb.18:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	iy, -3145600
	call	_os_ClrLCD
	call	_os_HomeUp
	call	_os_DrawStatusBar
	ld	hl, _.str.12
	push	hl
	ld	de, -638
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_strtok
	ex	de, hl
	pop	hl
	pop	hl
	ld	bc, 0
	.local	.LBB11_19
.LBB11_19:                              ;   Parent Loop BB11_1 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	sbc	hl, hl
	adc	hl, de
	jp	z, .LBB11_36
; %bb.20:                               ;   in Loop: Header=BB11_19 Depth=2
	push	bc
	pop	hl
	push	de
	pop	iy
	ld	de, 10
	or	a, a
	sbc	hl, de
	lea	de, iy + 0
	call	pe, __setflag
	jp	p, .LBB11_36
; %bb.21:                               ;   in Loop: Header=BB11_19 Depth=2
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 25
	ld	(iy + 0), bc
	ld	hl, 58
	push	hl
	push	de
	ld	bc, -668
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), de
	call	_strchr
	ex	de, hl
	pop	hl
	pop	hl
	push	de
	pop	bc
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB11_23
; %bb.22:                               ;   in Loop: Header=BB11_19 Depth=2
	push	bc
	pop	hl
	ld	(hl), 0
	inc	hl
	push	hl
	ld	de, -668
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, _.str.13
	push	hl
	ld	hl, 27
	push	hl
	ld	de, -641
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_snprintf
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	de, -641
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	ld	de, -665
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	inc	hl
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	.local	.LBB11_23
.LBB11_23:                              ;   in Loop: Header=BB11_19 Depth=2
	ld	hl, _.str.12
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	call	_strtok
	ex	de, hl
	pop	hl
	pop	hl
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 25
	ld	bc, (iy + 0)
	jp	.LBB11_19
	.local	.LBB11_24
.LBB11_24:                              ;   in Loop: Header=BB11_1 Depth=1
	ld	a, (_serial_open)
	bit	0, a
	ld	hl, _.str.9
	jp	z, .LBB11_27
; %bb.25:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	hl, -3145600
	push	hl
	pop	iy
	call	_os_ClrLCD
	ld	iy, -3145600
	call	_os_HomeUp
	call	_os_DrawStatusBar
	ld	hl, _.str.17
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	ld	hl, 64
	push	hl
	ld	de, -641
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, _.str.18
	push	hl
	call	_os_GetStringInput
	pop	hl
	pop	hl
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	ld	hl, _.str.19
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	ld	hl, 64
	push	hl
	ld	de, -644
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, _.str.18
	push	hl
	call	_os_GetStringInput
	pop	hl
	pop	hl
	pop	hl
	ld	de, -644
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	de, -641
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, _.str.20
	push	hl
	ld	hl, 300
	push	hl
	ld	de, -638
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_snprintf
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	de, -638
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_celink_send
	pop	hl
	bit	0, a
	ld	hl, _.str.21
	jr	nz, .LBB11_27
; %bb.26:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	hl, _.str.22
	.local	.LBB11_27
.LBB11_27:                              ;   in Loop: Header=BB11_1 Depth=1
	push	hl
	ld	hl, _.str.16
	jp	.LBB11_53
	.local	.LBB11_28
.LBB11_28:                              ;   in Loop: Header=BB11_1 Depth=1
	ld	hl, _.str.9
	.local	.LBB11_29
.LBB11_29:                              ;   in Loop: Header=BB11_1 Depth=1
	push	hl
	ld	hl, _.str.8
	jp	.LBB11_53
	.local	.LBB11_30
.LBB11_30:                              ;   in Loop: Header=BB11_1 Depth=1
	ld	a, (_serial_open)
	bit	0, a
	ld	hl, _.str.9
	jr	z, .LBB11_33
; %bb.31:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	hl, _.str.24
	push	hl
	call	_celink_send
	pop	hl
	bit	0, a
	ld	hl, _.str.25
	jr	nz, .LBB11_33
; %bb.32:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	hl, _.str.22
	.local	.LBB11_33
.LBB11_33:                              ;   in Loop: Header=BB11_1 Depth=1
	push	hl
	ld	hl, _.str.23
	jp	.LBB11_53
	.local	.LBB11_34
.LBB11_34:                              ;   in Loop: Header=BB11_1 Depth=1
	ld	de, -647
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	ld	a, (iy + 0)
	or	a, a
	ld	hl, _.str.11
	jr	z, .LBB11_29
; %bb.35:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	de, -638
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	jr	.LBB11_29
	.local	.LBB11_36
.LBB11_36:                              ;   in Loop: Header=BB11_1 Depth=1
	ld	iy, -3145600
	.local	.LBB11_37
.LBB11_37:                              ;   in Loop: Header=BB11_1 Depth=1
	call	_os_NewLine
	ld	hl, _.str.14
	push	hl
	call	_os_PutStrFull
	pop	hl
	call	_wait_for_any_key
	jp	.LBB11_54
	.local	.LBB11_38
.LBB11_38:                              ;   in Loop: Header=BB11_1 Depth=1
	ld	a, (_serial_open)
	bit	0, a
	ld	hl, _.str.9
	jr	z, .LBB11_42
; %bb.39:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	hl, 4000
	push	hl
	ld	hl, 256
	push	hl
	ld	de, -650
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, 2
	push	hl
	ld	hl, _.str.27
	push	hl
	call	_celink_request
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	bit	0, a
	ld	de, -650
	lea	iy, ix + 0
	push	af
	add	iy, de
	pop	af
	ld	hl, (iy + 0)
	jr	nz, .LBB11_42
; %bb.40:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	de, -647
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	ld	a, (iy + 0)
	or	a, a
	ld	hl, _.str.11
	jr	z, .LBB11_42
; %bb.41:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	de, -650
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	.local	.LBB11_42
.LBB11_42:                              ;   in Loop: Header=BB11_1 Depth=1
	push	hl
	ld	hl, _.str.26
	jp	.LBB11_53
	.local	.LBB11_43
.LBB11_43:                              ;   in Loop: Header=BB11_1 Depth=1
	ld	a, (_serial_open)
	bit	0, a
	ld	hl, _.str.9
	jp	z, .LBB11_47
; %bb.44:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	iy, -3145600
	call	_os_ClrLCD
	call	_os_HomeUp
	call	_os_DrawStatusBar
	ld	hl, 64
	push	hl
	ld	de, -644
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, _.str.29
	push	hl
	call	_os_GetStringInput
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 8
	push	hl
	ld	de, -659
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, _.str.30
	push	hl
	call	_os_GetStringInput
	pop	hl
	pop	hl
	pop	hl
	ld	de, -659
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	de, -644
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, _.str.31
	push	hl
	ld	hl, 300
	push	hl
	ld	de, -650
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_snprintf
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 8000
	push	hl
	ld	hl, 256
	push	hl
	ld	de, -653
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, 3
	push	hl
	ld	de, -650
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_celink_request
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	bit	0, a
	ld	de, -653
	lea	iy, ix + 0
	push	af
	add	iy, de
	pop	af
	ld	hl, (iy + 0)
	jr	nz, .LBB11_47
; %bb.45:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	de, -662
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	ld	a, (iy + 0)
	or	a, a
	ld	hl, _.str.11
	jr	z, .LBB11_47
; %bb.46:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	de, -653
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	.local	.LBB11_47
.LBB11_47:                              ;   in Loop: Header=BB11_1 Depth=1
	push	hl
	ld	hl, _.str.28
	jr	.LBB11_53
	.local	.LBB11_48
.LBB11_48:                              ;   in Loop: Header=BB11_1 Depth=1
	ld	a, (_serial_open)
	bit	0, a
	ld	hl, _.str.9
	jr	z, .LBB11_52
; %bb.49:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	hl, 4000
	push	hl
	ld	hl, 256
	push	hl
	ld	de, -656
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, 5
	push	hl
	ld	hl, _.str.33
	push	hl
	call	_celink_request
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	bit	0, a
	ld	de, -656
	lea	iy, ix + 0
	push	af
	add	iy, de
	pop	af
	ld	hl, (iy + 0)
	jr	nz, .LBB11_52
; %bb.50:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	de, -647
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	ld	a, (iy + 0)
	or	a, a
	ld	hl, _.str.11
	jr	z, .LBB11_52
; %bb.51:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	de, -656
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	.local	.LBB11_52
.LBB11_52:                              ;   in Loop: Header=BB11_1 Depth=1
	push	hl
	ld	hl, _.str.32
	.local	.LBB11_53
.LBB11_53:                              ;   in Loop: Header=BB11_1 Depth=1
	push	hl
	call	_show_result
	pop	hl
	pop	hl
	.local	.LBB11_54
.LBB11_54:                              ;   in Loop: Header=BB11_1 Depth=1
	ld	a, (_serial_open)
	ld	l, a
	jp	.LBB11_1
	.local	.LBB11_55
.LBB11_55:                              ;   in Loop: Header=BB11_1 Depth=1
	scf
	sbc	hl, hl
	ld	(ix - 70), hl
	ld	a, (_serial_open)
	bit	0, a
	jr	z, .LBB11_58
; %bb.56:                               ;   in Loop: Header=BB11_1 Depth=1
	ld	iy, -3145600
	call	_os_ClrLCD
	call	_os_HomeUp
	call	_os_DrawStatusBar
	ld	hl, 64
	push	hl
	ld	de, -653
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, _.str.35
	push	hl
	call	_os_GetStringInput
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 8000
	push	hl
	pea	ix - 70
	ld	hl, 2048
	push	hl
	ld	hl, _run_get.body
	push	hl
	ld	de, -653
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_celink_get
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 70)
	bit	0, a
	jr	z, .LBB11_59
; %bb.57:                               ;   in Loop: Header=BB11_1 Depth=1
	push	hl
	ld	hl, _.str.36
	jr	.LBB11_60
	.local	.LBB11_58
.LBB11_58:                              ;   in Loop: Header=BB11_1 Depth=1
	ld	hl, _.str.9
	push	hl
	ld	hl, _.str.34
	jp	.LBB11_53
	.local	.LBB11_59
.LBB11_59:                              ;   in Loop: Header=BB11_1 Depth=1
	push	hl
	ld	hl, _.str.37
	.local	.LBB11_60
.LBB11_60:                              ;   in Loop: Header=BB11_1 Depth=1
	push	hl
	ld	hl, 80
	push	hl
	ld	de, -656
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_snprintf
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, _run_get.body
	push	hl
	ld	de, -656
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	jp	.LBB11_53
	.local	.LBB11_61
.LBB11_61:
	call	_celink_disconnect
	or	a, a
	sbc	hl, hl
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end11
.Lfunc_end11:
	.size	_main, .Lfunc_end11-_main
                                        ; -- End function
	.section	.text._draw_menu,"ax",@progbits
	.type	_draw_menu,@function            ; -- Begin function draw_menu
_draw_menu:                             ; @draw_menu
; %bb.0:
	ld	hl, -1
	call	__frameset
	ld	a, (ix + 6)
	ld	(ix - 1), a
	ld	iy, -3145600
	call	_os_ClrLCD
	call	_os_HomeUp
	call	_os_DrawStatusBar
	ld	hl, _.str.7
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	call	_os_NewLine
	bit	0, (ix - 1)                     ; 1-byte Folded Reload
	jr	nz, .LBB12_2
; %bb.1:
	ld	hl, _.str.2.9
	jr	.LBB12_3
	.local	.LBB12_2
.LBB12_2:
	ld	hl, _.str.1.8
	.local	.LBB12_3
.LBB12_3:
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	hl, -3145600
	push	hl
	pop	iy
	call	_os_NewLine
	ld	iy, -3145600
	call	_os_NewLine
	ld	hl, _.str.3.10
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	ld	hl, _.str.4.11
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	ld	hl, _.str.5.12
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	ld	hl, _.str.6.13
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	call	_os_NewLine
	ld	hl, _.str.7.14
	ld	(ix + 6), hl
	inc	sp
	pop	ix
	jp	_os_PutStrFull
	.local	.Lfunc_end12
.Lfunc_end12:
	.size	_draw_menu, .Lfunc_end12-_draw_menu
                                        ; -- End function
	.section	.text._show_result,"ax",@progbits
	.type	_show_result,@function          ; -- Begin function show_result
_show_result:                           ; @show_result
; %bb.0:
	ld	hl, -6
	call	__frameset
	ld	hl, (ix + 6)
	ld	(ix - 6), hl
	ld	hl, (ix + 9)
	ld	(ix - 3), hl
	ld	iy, -3145600
	call	_os_ClrLCD
	call	_os_HomeUp
	call	_os_DrawStatusBar
	ld	hl, (ix - 6)
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	call	_os_NewLine
	ld	hl, (ix - 3)
	push	hl
	pop	de
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB13_2
; %bb.1:
	ld	hl, _.str.15
	jr	.LBB13_4
	.local	.LBB13_2
.LBB13_2:
	push	de
	pop	hl
	ld	a, (hl)
	or	a, a
	ld	hl, _.str.15
	jr	z, .LBB13_4
; %bb.3:
	ex	de, hl
	.local	.LBB13_4
.LBB13_4:
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	call	_os_NewLine
	ld	hl, _.str.14
	push	hl
	call	_os_PutStrFull
	ld	sp, ix
	pop	ix
	jp	_wait_for_any_key
	.local	.Lfunc_end13
.Lfunc_end13:
	.size	_show_result, .Lfunc_end13-_show_result
                                        ; -- End function
	.section	.text._wait_for_any_key,"ax",@progbits
	.type	_wait_for_any_key,@function     ; -- Begin function wait_for_any_key
_wait_for_any_key:                      ; @wait_for_any_key
; %bb.0:
	.local	.LBB14_1
.LBB14_1:                               ; =>This Inner Loop Header: Depth=1
	call	_os_GetCSC
	or	a, a
	jr	nz, .LBB14_1
	.local	.LBB14_2
.LBB14_2:                               ; %.preheader
                                        ; =>This Inner Loop Header: Depth=1
	call	_os_GetCSC
	or	a, a
	jr	z, .LBB14_2
; %bb.3:
	ret
	.local	.Lfunc_end14
.Lfunc_end14:
	.size	_wait_for_any_key, .Lfunc_end14-_wait_for_any_key
                                        ; -- End function
	.section	.bss._connected_device,"aw",@nobits
	.balign	1
	.local	_connected_device
_connected_device:
	.zero	3

	.section	.bss._usb_initialized,"aw",@nobits
	.balign	1
	.local	_usb_initialized
_usb_initialized:
	.zero	1

	.section	.bss._serial_open,"aw",@nobits
	.balign	1
	.local	_serial_open
_serial_open:
	.zero	1

	.section	.bss._last_error,"aw",@nobits
	.balign	1
	.local	_last_error
_last_error:
	.zero	3

	.section	.bss._srl_buffer,"aw",@nobits
	.balign	1
	.local	_srl_buffer
_srl_buffer:
	.zero	512

	.section	.bss._srl_dev,"aw",@nobits
	.balign	1
	.local	_srl_dev
_srl_dev:
	.zero	58

	.section	.rodata._.str,"a",@progbits
	.balign	1
	.local	_.str
_.str:
	.asciz	"Protocol mismatch (got code %d, expected %d)."

	.section	.rodata._.str.1,"a",@progbits
	.balign	1
	.local	_.str.1
_.str.1:
	.asciz	"get|%s|%u"

	.section	.rodata._.str.2,"a",@progbits
	.balign	1
	.local	_.str.2
_.str.2:
	.asciz	"Timed out waiting for header."

	.section	.rodata._.str.3,"a",@progbits
	.balign	1
	.local	_.str.3
_.str.3:
	.asciz	"Protocol mismatch (got code %d)."

	.section	.rodata._.str.4,"a",@progbits
	.balign	1
	.local	_.str.4
_.str.4:
	.asciz	"error|"

	.section	.rodata._.str.5,"a",@progbits
	.balign	1
	.local	_.str.5
_.str.5:
	.asciz	"Bad response header."

	.section	.rodata._.str.6,"a",@progbits
	.balign	1
	.local	_.str.6
_.str.6:
	.asciz	"Bad content length."

	.section	.rodata._.str.7,"a",@progbits
	.balign	1
	.local	_.str.7
_.str.7:
	.asciz	"=== CELinK DEMO ==="

	.section	.rodata._.str.1.8,"a",@progbits
	.balign	1
	.local	_.str.1.8
_.str.1.8:
	.asciz	"STATUS: CONNECTED"

	.section	.rodata._.str.2.9,"a",@progbits
	.balign	1
	.local	_.str.2.9
_.str.2.9:
	.asciz	"STATUS: WAITING..."

	.section	.rodata._.str.3.10,"a",@progbits
	.balign	1
	.local	_.str.3.10
_.str.3.10:
	.asciz	"1:Scan  2:Connect"

	.section	.rodata._.str.4.11,"a",@progbits
	.balign	1
	.local	_.str.4.11
_.str.4.11:
	.asciz	"3:Discon 4:Status"

	.section	.rodata._.str.5.12,"a",@progbits
	.balign	1
	.local	_.str.5.12
_.str.5.12:
	.asciz	"5:Ping  6:Help"

	.section	.rodata._.str.6.13,"a",@progbits
	.balign	1
	.local	_.str.6.13
_.str.6.13:
	.asciz	"7:Get"

	.section	.rodata._.str.7.14,"a",@progbits
	.balign	1
	.local	_.str.7.14
_.str.7.14:
	.asciz	"0:Debug  CLEAR:Quit"

	.section	.rodata._.str.8,"a",@progbits
	.balign	1
	.local	_.str.8
_.str.8:
	.asciz	"WIFI SCAN"

	.section	.rodata._.str.9,"a",@progbits
	.balign	1
	.local	_.str.9
_.str.9:
	.asciz	"Not connected to Pico."

	.section	.rodata._.str.10,"a",@progbits
	.balign	1
	.local	_.str.10
_.str.10:
	.asciz	"wifiscan"

	.section	.rodata._.str.11,"a",@progbits
	.balign	1
	.local	_.str.11
_.str.11:
	.asciz	"Timed out."

	.section	.rodata._.str.12,"a",@progbits
	.balign	1
	.local	_.str.12
_.str.12:
	.asciz	"|"

	.section	.rodata._.str.13,"a",@progbits
	.balign	1
	.local	_.str.13
_.str.13:
	.asciz	"%-16.16s %.9s"

	.section	.rodata._.str.14,"a",@progbits
	.balign	1
	.local	_.str.14
_.str.14:
	.asciz	"Press any key..."

	.section	.rodata._.str.15,"a",@progbits
	.balign	1
	.local	_.str.15
_.str.15:
	.asciz	"(no response)"

	.section	.rodata._.str.16,"a",@progbits
	.balign	1
	.local	_.str.16
_.str.16:
	.asciz	"CONNECT"

	.section	.rodata._.str.17,"a",@progbits
	.balign	1
	.local	_.str.17
_.str.17:
	.asciz	"SSID:"

	.section	.rodata._.str.18,"a",@progbits
	.balign	1
	.local	_.str.18
_.str.18:
	.zero	1

	.section	.rodata._.str.19,"a",@progbits
	.balign	1
	.local	_.str.19
_.str.19:
	.asciz	"PASSWORD:"

	.section	.rodata._.str.20,"a",@progbits
	.balign	1
	.local	_.str.20
_.str.20:
	.asciz	"connect|%s|%s"

	.section	.rodata._.str.21,"a",@progbits
	.balign	1
	.local	_.str.21
_.str.21:
	.asciz	"Sent. Check status to confirm."

	.section	.rodata._.str.22,"a",@progbits
	.balign	1
	.local	_.str.22
_.str.22:
	.asciz	"Failed to send."

	.section	.rodata._.str.23,"a",@progbits
	.balign	1
	.local	_.str.23
_.str.23:
	.asciz	"DISCONNECT"

	.section	.rodata._.str.24,"a",@progbits
	.balign	1
	.local	_.str.24
_.str.24:
	.asciz	"disconnect"

	.section	.rodata._.str.25,"a",@progbits
	.balign	1
	.local	_.str.25
_.str.25:
	.asciz	"Sent."

	.section	.rodata._.str.26,"a",@progbits
	.balign	1
	.local	_.str.26
_.str.26:
	.asciz	"STATUS"

	.section	.rodata._.str.27,"a",@progbits
	.balign	1
	.local	_.str.27
_.str.27:
	.asciz	"wifiisconnected"

	.section	.rodata._.str.28,"a",@progbits
	.balign	1
	.local	_.str.28
_.str.28:
	.asciz	"PING"

	.section	.rodata._.str.29,"a",@progbits
	.balign	1
	.local	_.str.29
_.str.29:
	.asciz	"HOST/IP:"

	.section	.rodata._.str.30,"a",@progbits
	.balign	1
	.local	_.str.30
_.str.30:
	.asciz	"TIMEOUT(s):"

	.section	.rodata._.str.31,"a",@progbits
	.balign	1
	.local	_.str.31
_.str.31:
	.asciz	"ping|%s|%s"

	.section	.rodata._.str.32,"a",@progbits
	.balign	1
	.local	_.str.32
_.str.32:
	.asciz	"HELP"

	.section	.rodata._.str.33,"a",@progbits
	.balign	1
	.local	_.str.33
_.str.33:
	.asciz	"help"

	.section	.bss._run_get.body,"aw",@nobits
	.balign	1
	.local	_run_get.body
_run_get.body:
	.zero	2048

	.section	.rodata._.str.34,"a",@progbits
	.balign	1
	.local	_.str.34
_.str.34:
	.asciz	"GET"

	.section	.rodata._.str.35,"a",@progbits
	.balign	1
	.local	_.str.35
_.str.35:
	.asciz	"URL:"

	.section	.rodata._.str.36,"a",@progbits
	.balign	1
	.local	_.str.36
_.str.36:
	.asciz	"GET %d"

	.section	.rodata._.str.37,"a",@progbits
	.balign	1
	.local	_.str.37
_.str.37:
	.asciz	"GET FAILED (%d)"

	.section	.rodata._.str.38,"a",@progbits
	.balign	1
	.local	_.str.38
_.str.38:
	.asciz	"=== CELinK DEBUG ==="

	.section	.rodata._.str.39,"a",@progbits
	.balign	1
	.local	_.str.39
_.str.39:
	.asciz	"SERIAL: OPEN"

	.section	.rodata._.str.40,"a",@progbits
	.balign	1
	.local	_.str.40
_.str.40:
	.asciz	"SERIAL: CLOSED"

	.section	.rodata._.str.41,"a",@progbits
	.balign	1
	.local	_.str.41
_.str.41:
	.asciz	"LAST ERROR: %d"

	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.section	".note.GNU-stack","",@progbits
	.extern	_os_HomeUp
	.extern	_usb_Cleanup
	.extern	_llvm.eh.sjlj.functioncontext
	.extern	_usb_GetRole
	.extern	_usb_HandleEvents
	.extern	_strncpy
	.extern	_llvm.lifetime.end.p0
	.extern	_srl_Write
	.extern	__lcmps
	.extern	_llvm.memmove.p0.p0.i24
	.extern	_os_GetStringInput
	.extern	_llvm.eh.sjlj.lsda
	.extern	__Unwind_SjLj_Unregister
	.extern	_strlen
	.extern	_memmove
	.extern	__frameset
	.extern	_kb_Scan
	.extern	_atol
	.extern	_srl_UsbEventCallback
	.extern	_usb_Init
	.extern	__setflag
	.extern	_atoi
	.extern	_strtok
	.extern	_srl_Close
	.extern	_os_ClrLCD
	.extern	_os_GetCSC
	.extern	_llvm.eh.sjlj.callsite
	.extern	_llvm.eh.sjlj.setup.dispatch
	.extern	_llvm.stacksave.p0
	.extern	__lcmpzero
	.extern	_srl_Open
	.extern	_memcmp
	.extern	_llvm.lifetime.start.p0
	.extern	__frameset0
	.extern	__Unwind_SjLj_Register
	.extern	_llvm.frameaddress.p0
	.extern	_os_DrawStatusBar
	.extern	_os_PutStrFull
	.extern	__sand
	.extern	_llvm.stackrestore.p0
	.extern	_usb_RefDevice
	.extern	_snprintf
	.extern	_sprintf
	.extern	_usb_ResetDevice
	.extern	_os_NewLine
	.extern	_usb_UnrefDevice
	.extern	_strchr
	.extern	_srl_Read
