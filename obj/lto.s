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
	ld	hl, -4
	call	__frameset
	ld	hl, (ix + 9)
	xor	a, a
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB6_8
; %bb.1:
	ld	hl, (ix + 12)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB6_8
; %bb.2:
	ld	de, (ix + 6)
	ld	hl, (ix + 9)
	ld	(hl), 0
	push	de
	call	_celink_send
	pop	hl
	bit	0, a
	ld	a, 0
	jr	z, .LBB6_8
; %bb.3:                                ; %.preheader.preheader
	ld	de, (ix + 15)
	inc	de
	ld	c, -1
	ld	b, 0
	.local	.LBB6_4
.LBB6_4:                                ; %.preheader
                                        ; =>This Inner Loop Header: Depth=1
	dec	de
	sbc	hl, hl
	adc	hl, de
	ld	a, c
	jr	nz, .LBB6_6
; %bb.5:                                ; %.preheader
                                        ;   in Loop: Header=BB6_4 Depth=1
	ld	a, b
	.local	.LBB6_6
.LBB6_6:                                ; %.preheader
                                        ;   in Loop: Header=BB6_4 Depth=1
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB6_8
; %bb.7:                                ;   in Loop: Header=BB6_4 Depth=1
	ld	(ix - 1), a                     ; 1-byte Folded Spill
	ld	(ix - 4), de
	call	_celink_process
	ld	hl, (ix + 12)
	push	hl
	ld	hl, (ix + 9)
	push	hl
	call	_celink_read
	ld	b, 0
	ld	c, -1
	ld	a, (ix - 1)                     ; 1-byte Folded Reload
	pop	de
	pop	de
	ld	de, (ix - 4)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB6_4
	.local	.LBB6_8
.LBB6_8:                                ; %.loopexit
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end6
.Lfunc_end6:
	.size	_celink_request, .Lfunc_end6-_celink_request
                                        ; -- End function
	.section	.text._celink_last_error,"ax",@progbits
	.globl	_celink_last_error              ; -- Begin function celink_last_error
	.type	_celink_last_error,@function
_celink_last_error:                     ; @celink_last_error
; %bb.0:
	ld	hl, (_last_error)
	ret
	.local	.Lfunc_end7
.Lfunc_end7:
	.size	_celink_last_error, .Lfunc_end7-_celink_last_error
                                        ; -- End function
	.section	.text._celink_get,"ax",@progbits
	.globl	_celink_get                     ; -- Begin function celink_get
	.type	_celink_get,@function
_celink_get:                            ; @celink_get
; %bb.0:
	ld	hl, -807
	call	__frameset
	ld	hl, (ix + 15)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB8_2
; %bb.1:
	scf
	sbc	hl, hl
	ld	iy, (ix + 15)
	ld	(iy), hl
	.local	.LBB8_2
.LBB8_2:
	ld	e, 0
	ld	hl, (ix + 9)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB8_35
; %bb.3:
	ld	bc, (ix + 12)
	sbc	hl, hl
	adc	hl, bc
	jp	z, .LBB8_35
; %bb.4:
	push	bc
	pop	iy
	ld	bc, (ix + 6)
	ld	hl, (ix + 9)
	ld	(hl), 0
	sbc	hl, hl
	adc	hl, bc
	jp	z, .LBB8_35
; %bb.5:
	ld	a, (_serial_open)
	bit	0, a
	jp	z, .LBB8_35
; %bb.6:
	ld	de, 512
	lea	bc, iy + 0
	ld	iy, _.str
	push	de
	ld	de, -518
	lea	hl, ix + 0
	add	hl, de
	pop	de
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 9
	ld	(ix + 0), hl
	pop	ix
	dec	bc
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 12
	ld	(ix + 0), bc
	pop	ix
	push	bc
	ld	bc, (ix + 6)
	push	bc
	push	iy
	push	de
	push	hl
	call	_snprintf
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	de, -777
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_celink_send
	pop	hl
	bit	0, a
	jp	z, .LBB8_34
; %bb.7:                                ; %.preheader22.preheader
	ld	de, -774
	lea	iy, ix + 0
	add	iy, de
	ld	de, (ix + 18)
	or	a, a
	sbc	hl, hl
	xor	a, a
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 6
	lea	bc, ix + 0
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
	lea	bc, iy + 64
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 27
	ld	(ix + 0), bc
	pop	ix
	lea	iy, iy + 0
	push	ix
	ld	bc, -783
	add	ix, bc
	ld	(ix + 0), hl
	pop	ix
	push	ix
	ld	bc, -789
	add	ix, bc
	ld	(ix + 0), hl
	pop	ix
	push	ix
	ld	bc, -792
	add	ix, bc
	ld	(ix + 0), hl
	pop	ix
	.local	.LBB8_8
.LBB8_8:                                ; %.preheader22
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB8_13 Depth 2
                                        ;     Child Loop BB8_20 Depth 2
	bit	0, a
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
	jp	nz, .LBB8_25
; %bb.9:                                ; %.preheader22
                                        ;   in Loop: Header=BB8_8 Depth=1
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 15
	ld	hl, (ix + 0)
	pop	ix
	or	a, a
	sbc	hl, de
	jp	nc, .LBB8_25
; %bb.10:                               ;   in Loop: Header=BB8_8 Depth=1
	ld	de, -786
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	call	_celink_process
	ld	hl, 64
	push	hl
	ld	de, -786
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_celink_read
	ex	de, hl
	pop	hl
	pop	hl
	ld	bc, -798
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), de
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB8_12
; %bb.11:                               ;   in Loop: Header=BB8_8 Depth=1
	ld	de, -783
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	inc	hl
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	xor	a, a
	jp	.LBB8_24
	.local	.LBB8_12
.LBB8_12:                               ;   in Loop: Header=BB8_8 Depth=1
	ld	de, 0
	ld	bc, -786
	lea	hl, ix + 0
	add	hl, bc
	ld	iy, (hl)
	.local	.LBB8_13
.LBB8_13:                               ; %.preheader21
                                        ;   Parent Loop BB8_8 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	push	ix
	ld	bc, -798
	add	ix, bc
	ld	hl, (ix + 0)
	pop	ix
	or	a, a
	sbc	hl, de
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 21
	ld	bc, (ix + 0)
	pop	ix
	jp	z, .LBB8_18
; %bb.14:                               ;   in Loop: Header=BB8_13 Depth=2
	lea	hl, iy + 0
	add	hl, de
	ld	a, (hl)
	cp	a, 10
	jp	z, .LBB8_19
; %bb.15:                               ;   in Loop: Header=BB8_13 Depth=2
	push	bc
	pop	hl
	inc	hl
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 15
	ld	(ix + 0), hl
	pop	ix
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 21
	ld	(ix + 0), bc
	pop	ix
	ld	bc, 128
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB8_17
; %bb.16:                               ;   in Loop: Header=BB8_13 Depth=2
	ld	bc, -777
	lea	hl, ix + 0
	add	hl, bc
	ld	iy, (hl)
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 21
	ld	bc, (ix + 0)
	pop	ix
	add	iy, bc
	ld	(iy), a
	ld	bc, -786
	lea	hl, ix + 0
	add	hl, bc
	ld	iy, (hl)
	push	ix
	ld	bc, -783
	add	ix, bc
	ld	hl, (ix + 0)
	pop	ix
	push	ix
	ld	bc, -789
	add	ix, bc
	ld	(ix + 0), hl
	pop	ix
	.local	.LBB8_17
.LBB8_17:                               ;   in Loop: Header=BB8_13 Depth=2
	inc	de
	jp	.LBB8_13
	.local	.LBB8_18
.LBB8_18:                               ;   in Loop: Header=BB8_8 Depth=1
	ld	de, -777
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	add	iy, bc
	ld	(iy), 0
	ld	de, -786
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	or	a, a
	sbc	hl, hl
	push	ix
	ld	de, -783
	add	ix, de
	ld	(ix + 0), hl
	pop	ix
	xor	a, a
	ld	de, (ix + 18)
	jp	.LBB8_8
	.local	.LBB8_19
.LBB8_19:                               ;   in Loop: Header=BB8_8 Depth=1
	lea	hl, iy + 0
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 9
	ld	iy, (ix + 0)
	pop	ix
	add	iy, bc
	ld	(iy), 0
	push	ix
	ld	bc, -795
	add	ix, bc
	ld	iy, (ix + 0)
	pop	ix
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 24
	ld	bc, (ix + 0)
	pop	ix
	add	iy, bc
	push	ix
	ld	bc, -804
	add	ix, bc
	ld	(ix + 0), iy
	pop	ix
	add	hl, de
	ld	bc, -807
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	ld	bc, 0
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 33
	ld	(iy + 0), de
	.local	.LBB8_20
.LBB8_20:                               ;   Parent Loop BB8_8 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
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
	add	iy, bc
	ex	de, hl
	push	ix
	ld	de, -783
	add	ix, de
	ld	(ix + 0), bc
	pop	ix
	add	hl, bc
	inc	hl
	push	ix
	ld	bc, -798
	add	ix, bc
	ld	de, (ix + 0)
	pop	ix
	or	a, a
	sbc	hl, de
	call	pe, __setflag
	jp	p, .LBB8_23
; %bb.21:                               ;   in Loop: Header=BB8_20 Depth=2
	lea	hl, iy + 0
	ld	bc, 64
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB8_23
; %bb.22:                               ;   in Loop: Header=BB8_20 Depth=2
	ld	de, -807
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	ld	de, -783
	lea	hl, ix + 0
	add	hl, de
	ld	bc, (hl)
	add	iy, bc
	ld	a, (iy + 1)
	ld	de, -804
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	add	hl, bc
	ld	(hl), a
	inc	bc
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 33
	ld	de, (iy + 0)
	jp	.LBB8_20
	.local	.LBB8_23
.LBB8_23:                               ; %.loopexit20.loopexit
                                        ;   in Loop: Header=BB8_8 Depth=1
	ld	de, -792
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	ld	bc, -783
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	add	hl, de
	ld	de, 0
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), de
	ld	a, 1
	ld	de, -792
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	.local	.LBB8_24
.LBB8_24:                               ; %.preheader22
                                        ;   in Loop: Header=BB8_8 Depth=1
	ld	de, (ix + 18)
	ld	bc, -786
	lea	hl, ix + 0
	add	hl, bc
	ld	iy, (hl)
	jp	.LBB8_8
	.local	.LBB8_25
.LBB8_25:
	bit	0, a
	jr	z, .LBB8_28
; %bb.26:
	ld	de, -786
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	ld	hl, 6
	push	hl
	ld	hl, _.str.2
	push	hl
	push	bc
	call	_memcmp
	pop	de
	pop	de
	pop	de
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB8_29
; %bb.27:
	ld	de, -780
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	de, -777
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	pea	iy + 6
	jr	.LBB8_33
	.local	.LBB8_28
.LBB8_28:
	ld	de, -780
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, _.str.1
	jr	.LBB8_32
	.local	.LBB8_29
.LBB8_29:
	ld	hl, 124
	push	hl
	ld	de, -777
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
	jr	z, .LBB8_31
; %bb.30:
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
	jr	nz, .LBB8_36
	.local	.LBB8_31
.LBB8_31:
	ld	de, -780
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, _.str.3
	.local	.LBB8_32
.LBB8_32:
	push	hl
	.local	.LBB8_33
.LBB8_33:
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
	.local	.LBB8_34
.LBB8_34:
	ld	e, 0
	.local	.LBB8_35
.LBB8_35:
	ld	a, e
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB8_36
.LBB8_36:
	ld	hl, (ix + 15)
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	z, .LBB8_38
; %bb.37:
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
	.local	.LBB8_38
.LBB8_38:
	inc	bc
	push	bc
	call	_atol
	push	hl
	pop	iy
	ld	a, e
	pop	hl
	lea	hl, iy + 0
	call	__lcmpzero
	jp	p, .LBB8_40
; %bb.39:
	ld	de, -780
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, _.str.4
	jr	.LBB8_32
	.local	.LBB8_40
.LBB8_40:
	ld	bc, 0
	ld	de, -789
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), iy
	ld	de, -783
	lea	hl, ix + 0
	add	hl, de
	ld	(hl), a
	.local	.LBB8_41
.LBB8_41:                               ; %.preheader19
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
	lea	ix, ix - 24
	ld	de, (ix + 0)
	pop	ix
	or	a, a
	sbc	hl, de
	jr	nc, .LBB8_44
; %bb.42:                               ; %.preheader19
                                        ;   in Loop: Header=BB8_41 Depth=1
	push	bc
	pop	de
	inc	de
	push	de
	pop	hl
	push	bc
	pop	iy
	ld	bc, (ix + 12)
	or	a, a
	sbc	hl, bc
	jr	nc, .LBB8_45
; %bb.43:                               ;   in Loop: Header=BB8_41 Depth=1
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
	ld	bc, -783
	lea	iy, ix + 0
	add	iy, bc
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	push	de
	pop	bc
	ld	de, -789
	lea	hl, ix + 0
	add	hl, de
	ld	iy, (hl)
	jr	.LBB8_41
	.local	.LBB8_44
.LBB8_44:
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
	jp	.LBB8_54
	.local	.LBB8_45
.LBB8_45:
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
	lea	ix, ix - 21
	ld	iy, (ix + 0)
	jp	.LBB8_54
	.local	.LBB8_46
.LBB8_46:                               ; %.preheader18
                                        ;   in Loop: Header=BB8_54 Depth=1
	push	ix
	ld	de, -780
	add	ix, de
	ld	hl, (ix + 0)
	pop	ix
	ld	de, (ix + 18)
	or	a, a
	sbc	hl, de
	jp	nc, .LBB8_55
; %bb.47:                               ;   in Loop: Header=BB8_54 Depth=1
	call	_celink_process
	ld	hl, 64
	push	hl
	ld	de, -786
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_celink_read
	ex	de, hl
	pop	hl
	pop	hl
	ld	bc, -792
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), de
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB8_49
; %bb.48:                               ;   in Loop: Header=BB8_54 Depth=1
	ld	de, -780
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	inc	hl
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	ld	de, 0
	ld	bc, -789
	lea	hl, ix + 0
	add	hl, bc
	ld	iy, (hl)
	ld	bc, -783
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
	jp	.LBB8_54
	.local	.LBB8_49
.LBB8_49:                               ; %.preheader.preheader
                                        ;   in Loop: Header=BB8_54 Depth=1
	ld	hl, (ix + 9)
	ld	bc, -777
	lea	iy, ix + 0
	add	iy, bc
	ld	de, (iy + 0)
	add	hl, de
	ld	bc, -780
	lea	iy, ix + 0
	add	iy, bc
	ld	(iy + 0), hl
	ld	bc, 0
	.local	.LBB8_50
.LBB8_50:                               ; %.preheader
                                        ;   Parent Loop BB8_54 Depth=1
                                        ; =>  This Inner Loop Header: Depth=2
	push	de
	pop	iy
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
	lea	ix, ix - 24
	ld	de, (ix + 0)
	pop	ix
	or	a, a
	sbc	hl, de
	jr	nc, .LBB8_53
; %bb.51:                               ; %.preheader
                                        ;   in Loop: Header=BB8_50 Depth=2
	inc	iy
	lea	hl, iy + 0
	ld	de, (ix + 12)
	or	a, a
	sbc	hl, de
	jr	nc, .LBB8_53
; %bb.52:                               ;   in Loop: Header=BB8_50 Depth=2
	ld	de, -786
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
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 9
	ld	de, (iy + 0)
	jr	.LBB8_50
	.local	.LBB8_53
.LBB8_53:                               ; %.loopexit.loopexit
                                        ;   in Loop: Header=BB8_54 Depth=1
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
	lea	ix, ix - 21
	ld	iy, (ix + 0)
	pop	ix
	push	ix
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 128
	lea	ix, ix - 15
	ld	a, (ix + 0)                     ; 1-byte Folded Reload
	.local	.LBB8_54
.LBB8_54:                               ; %.preheader18
                                        ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB8_50 Depth 2
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
	jp	m, .LBB8_46
	.local	.LBB8_55
.LBB8_55:
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
	lea	iy, iy - 15
	ld	a, (iy + 0)                     ; 1-byte Folded Reload
	call	__lcmps
	call	pe, __setflag
	jp	p, .LBB8_57
; %bb.56:
	ld	e, 0
	jr	.LBB8_58
	.local	.LBB8_57
.LBB8_57:
	ld	e, 1
	.local	.LBB8_58
.LBB8_58:
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
	jp	.LBB8_35
	.local	.Lfunc_end8
.Lfunc_end8:
	.size	_celink_get, .Lfunc_end8-_celink_get
                                        ; -- End function
	.section	.text._celink_disconnect,"ax",@progbits
	.globl	_celink_disconnect              ; -- Begin function celink_disconnect
	.type	_celink_disconnect,@function
_celink_disconnect:                     ; @celink_disconnect
; %bb.0:
	ld	a, (_serial_open)
	bit	0, a
	jr	z, .LBB9_2
; %bb.1:
	ld	hl, _srl_dev
	push	hl
	call	_srl_Close
	pop	hl
	xor	a, a
	ld	(_serial_open), a
	.local	.LBB9_2
.LBB9_2:
	ld	de, (_connected_device)
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB9_4
; %bb.3:
	push	de
	call	_usb_UnrefDevice
	pop	hl
	or	a, a
	sbc	hl, hl
	ld	(_connected_device), hl
	.local	.LBB9_4
.LBB9_4:
	ld	a, (_usb_initialized)
	bit	0, a
	jr	z, .LBB9_6
; %bb.5:
	call	_usb_Cleanup
	xor	a, a
	ld	(_usb_initialized), a
	.local	.LBB9_6
.LBB9_6:
	ret
	.local	.Lfunc_end9
.Lfunc_end9:
	.size	_celink_disconnect, .Lfunc_end9-_celink_disconnect
                                        ; -- End function
	.section	.text._main,"ax",@progbits
	.globl	_main                           ; -- Begin function main
	.type	_main,@function
_main:                                  ; @main
; %bb.0:
	ld	hl, -656
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
	lea	iy, iy - 13
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
	lea	iy, iy - 10
	ld	(iy + 0), hl
	lea	hl, ix - 70
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 1
	ld	(iy + 0), hl
	lea	hl, ix - 78
	lea	iy, ix + 0
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 128
	lea	iy, iy - 16
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
	lea	iy, iy - 7
	ld	(iy + 0), hl
	push	de
	pop	iy
	lea	hl, iy + 0
	ld	de, -644
	lea	iy, ix + 0
	add	iy, de
	ld	(iy + 0), hl
	push	bc
	pop	iy
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
	.local	.LBB10_1
.LBB10_1:                               ; =>This Loop Header: Depth=1
                                        ;     Child Loop BB10_2 Depth 2
	push	hl
	call	_draw_menu
	pop	hl
	.local	.LBB10_2
.LBB10_2:                               ;   Parent Loop BB10_1 Depth=1
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
	jr	z, .LBB10_4
; %bb.3:                                ;   in Loop: Header=BB10_2 Depth=2
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
	.local	.LBB10_4
.LBB10_4:                               ;   in Loop: Header=BB10_2 Depth=2
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
	jp	nz, .LBB10_48
; %bb.5:                                ;   in Loop: Header=BB10_2 Depth=2
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
	jp	nz, .LBB10_16
; %bb.6:                                ;   in Loop: Header=BB10_2 Depth=2
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
	jp	nz, .LBB10_20
; %bb.7:                                ;   in Loop: Header=BB10_2 Depth=2
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
	jp	nz, .LBB10_24
; %bb.8:                                ;   in Loop: Header=BB10_2 Depth=2
	ld	l, (iy)
	ld	h, (iy + 1)
	ld	a, l
	bit	2, a
	jp	nz, .LBB10_28
; %bb.9:                                ;   in Loop: Header=BB10_2 Depth=2
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
	jp	nz, .LBB10_32
; %bb.10:                               ;   in Loop: Header=BB10_2 Depth=2
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
	jp	nz, .LBB10_36
; %bb.11:                               ;   in Loop: Header=BB10_2 Depth=2
	ld	l, (iy)
	ld	h, (iy + 1)
	ld	a, l
	bit	3, a
	jp	nz, .LBB10_42
; %bb.12:                               ;   in Loop: Header=BB10_2 Depth=2
	ld	l, (iy)
	ld	h, (iy + 1)
	ld.sis	bc, 1
	call	__sand
	bit	0, l
	jp	z, .LBB10_2
; %bb.13:                               ;   in Loop: Header=BB10_1 Depth=1
	ld	hl, -3145600
	push	hl
	pop	iy
	call	_os_ClrLCD
	ld	iy, -3145600
	call	_os_HomeUp
	call	_os_DrawStatusBar
	ld	hl, _.str.35
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	call	_os_NewLine
	ld	a, (_serial_open)
	bit	0, a
	ld	hl, _.str.36
	jr	nz, .LBB10_15
; %bb.14:                               ;   in Loop: Header=BB10_1 Depth=1
	ld	hl, _.str.37
	.local	.LBB10_15
.LBB10_15:                              ;   in Loop: Header=BB10_1 Depth=1
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	hl, -3145600
	push	hl
	pop	iy
	call	_os_NewLine
	ld	hl, (_last_error)
	push	hl
	ld	hl, _.str.38
	push	hl
	ld	de, -653
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_sprintf
	pop	hl
	pop	hl
	pop	hl
	ld	de, -653
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	call	_os_NewLine
	ld	hl, _.str.13
	push	hl
	call	_os_PutStrFull
	pop	hl
	call	_wait_for_any_key
	jp	.LBB10_41
	.local	.LBB10_16
.LBB10_16:                              ;   in Loop: Header=BB10_1 Depth=1
	ld	a, (_serial_open)
	bit	0, a
	ld	hl, _.str.9
	jr	z, .LBB10_19
; %bb.17:                               ;   in Loop: Header=BB10_1 Depth=1
	ld	hl, 15000
	push	hl
	ld	hl, 256
	push	hl
	ld	de, -638
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, _.str.10
	push	hl
	call	_celink_request
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	bit	0, a
	ld	de, -638
	lea	iy, ix + 0
	push	af
	add	iy, de
	pop	af
	ld	hl, (iy + 0)
	jr	nz, .LBB10_19
; %bb.18:                               ;   in Loop: Header=BB10_1 Depth=1
	ld	hl, _.str.11
	.local	.LBB10_19
.LBB10_19:                              ;   in Loop: Header=BB10_1 Depth=1
	push	hl
	ld	hl, _.str.8
	jp	.LBB10_40
	.local	.LBB10_20
.LBB10_20:                              ;   in Loop: Header=BB10_1 Depth=1
	ld	a, (_serial_open)
	bit	0, a
	ld	hl, _.str.9
	jp	z, .LBB10_23
; %bb.21:                               ;   in Loop: Header=BB10_1 Depth=1
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
	ld	hl, _.str.15
	push	hl
	call	_os_GetStringInput
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 64
	push	hl
	ld	de, -641
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, _.str.16
	push	hl
	call	_os_GetStringInput
	pop	hl
	pop	hl
	pop	hl
	ld	de, -641
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	de, -644
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, _.str.17
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
	ld	hl, _.str.18
	jr	nz, .LBB10_23
; %bb.22:                               ;   in Loop: Header=BB10_1 Depth=1
	ld	hl, _.str.19
	.local	.LBB10_23
.LBB10_23:                              ;   in Loop: Header=BB10_1 Depth=1
	push	hl
	ld	hl, _.str.14
	jp	.LBB10_40
	.local	.LBB10_24
.LBB10_24:                              ;   in Loop: Header=BB10_1 Depth=1
	ld	a, (_serial_open)
	bit	0, a
	ld	hl, _.str.9
	jr	z, .LBB10_27
; %bb.25:                               ;   in Loop: Header=BB10_1 Depth=1
	ld	hl, _.str.21
	push	hl
	call	_celink_send
	pop	hl
	bit	0, a
	ld	hl, _.str.22
	jr	nz, .LBB10_27
; %bb.26:                               ;   in Loop: Header=BB10_1 Depth=1
	ld	hl, _.str.19
	.local	.LBB10_27
.LBB10_27:                              ;   in Loop: Header=BB10_1 Depth=1
	push	hl
	ld	hl, _.str.20
	jp	.LBB10_40
	.local	.LBB10_28
.LBB10_28:                              ;   in Loop: Header=BB10_1 Depth=1
	ld	a, (_serial_open)
	bit	0, a
	ld	hl, _.str.9
	jr	z, .LBB10_31
; %bb.29:                               ;   in Loop: Header=BB10_1 Depth=1
	ld	hl, 4000
	push	hl
	ld	hl, 256
	push	hl
	ld	de, -647
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, _.str.24
	push	hl
	call	_celink_request
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	bit	0, a
	ld	de, -647
	lea	iy, ix + 0
	push	af
	add	iy, de
	pop	af
	ld	hl, (iy + 0)
	jr	nz, .LBB10_31
; %bb.30:                               ;   in Loop: Header=BB10_1 Depth=1
	ld	hl, _.str.11
	.local	.LBB10_31
.LBB10_31:                              ;   in Loop: Header=BB10_1 Depth=1
	push	hl
	ld	hl, _.str.23
	jp	.LBB10_40
	.local	.LBB10_32
.LBB10_32:                              ;   in Loop: Header=BB10_1 Depth=1
	ld	a, (_serial_open)
	bit	0, a
	ld	hl, _.str.9
	jp	z, .LBB10_35
; %bb.33:                               ;   in Loop: Header=BB10_1 Depth=1
	ld	iy, -3145600
	call	_os_ClrLCD
	call	_os_HomeUp
	call	_os_DrawStatusBar
	ld	hl, 64
	push	hl
	ld	de, -641
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, _.str.26
	push	hl
	call	_os_GetStringInput
	pop	hl
	pop	hl
	pop	hl
	ld	hl, 8
	push	hl
	ld	de, -656
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, _.str.27
	push	hl
	call	_os_GetStringInput
	pop	hl
	pop	hl
	pop	hl
	ld	de, -656
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	de, -641
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, _.str.28
	push	hl
	ld	hl, 300
	push	hl
	ld	de, -647
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
	ld	de, -650
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	de, -647
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	call	_celink_request
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
	jr	nz, .LBB10_35
; %bb.34:                               ;   in Loop: Header=BB10_1 Depth=1
	ld	hl, _.str.11
	.local	.LBB10_35
.LBB10_35:                              ;   in Loop: Header=BB10_1 Depth=1
	push	hl
	ld	hl, _.str.25
	jr	.LBB10_40
	.local	.LBB10_36
.LBB10_36:                              ;   in Loop: Header=BB10_1 Depth=1
	ld	a, (_serial_open)
	bit	0, a
	ld	hl, _.str.9
	jr	z, .LBB10_39
; %bb.37:                               ;   in Loop: Header=BB10_1 Depth=1
	ld	hl, 4000
	push	hl
	ld	hl, 256
	push	hl
	ld	de, -653
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, _.str.30
	push	hl
	call	_celink_request
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
	jr	nz, .LBB10_39
; %bb.38:                               ;   in Loop: Header=BB10_1 Depth=1
	ld	hl, _.str.11
	.local	.LBB10_39
.LBB10_39:                              ;   in Loop: Header=BB10_1 Depth=1
	push	hl
	ld	hl, _.str.29
	.local	.LBB10_40
.LBB10_40:                              ;   in Loop: Header=BB10_1 Depth=1
	push	hl
	call	_show_result
	pop	hl
	pop	hl
	.local	.LBB10_41
.LBB10_41:                              ;   in Loop: Header=BB10_1 Depth=1
	ld	a, (_serial_open)
	ld	l, a
	jp	.LBB10_1
	.local	.LBB10_42
.LBB10_42:                              ;   in Loop: Header=BB10_1 Depth=1
	scf
	sbc	hl, hl
	ld	(ix - 70), hl
	ld	a, (_serial_open)
	bit	0, a
	jr	z, .LBB10_45
; %bb.43:                               ;   in Loop: Header=BB10_1 Depth=1
	ld	iy, -3145600
	call	_os_ClrLCD
	call	_os_HomeUp
	call	_os_DrawStatusBar
	ld	hl, 64
	push	hl
	ld	de, -650
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	push	hl
	ld	hl, _.str.32
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
	ld	de, -650
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
	jr	z, .LBB10_46
; %bb.44:                               ;   in Loop: Header=BB10_1 Depth=1
	push	hl
	ld	hl, _.str.33
	jr	.LBB10_47
	.local	.LBB10_45
.LBB10_45:                              ;   in Loop: Header=BB10_1 Depth=1
	ld	hl, _.str.9
	push	hl
	ld	hl, _.str.31
	jp	.LBB10_40
	.local	.LBB10_46
.LBB10_46:                              ;   in Loop: Header=BB10_1 Depth=1
	push	hl
	ld	hl, _.str.34
	.local	.LBB10_47
.LBB10_47:                              ;   in Loop: Header=BB10_1 Depth=1
	push	hl
	ld	hl, 80
	push	hl
	ld	de, -653
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
	ld	de, -653
	lea	iy, ix + 0
	add	iy, de
	ld	hl, (iy + 0)
	jp	.LBB10_40
	.local	.LBB10_48
.LBB10_48:
	call	_celink_disconnect
	or	a, a
	sbc	hl, hl
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end10
.Lfunc_end10:
	.size	_main, .Lfunc_end10-_main
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
	ld	hl, _.str.5
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	call	_os_NewLine
	bit	0, (ix - 1)                     ; 1-byte Folded Reload
	jr	nz, .LBB11_2
; %bb.1:
	ld	hl, _.str.2.7
	jr	.LBB11_3
	.local	.LBB11_2
.LBB11_2:
	ld	hl, _.str.1.6
	.local	.LBB11_3
.LBB11_3:
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	hl, -3145600
	push	hl
	pop	iy
	call	_os_NewLine
	ld	iy, -3145600
	call	_os_NewLine
	ld	hl, _.str.3.8
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	ld	hl, _.str.4.9
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	ld	hl, _.str.5.10
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	ld	hl, _.str.6
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	call	_os_NewLine
	ld	hl, _.str.7
	ld	(ix + 6), hl
	inc	sp
	pop	ix
	jp	_os_PutStrFull
	.local	.Lfunc_end11
.Lfunc_end11:
	.size	_draw_menu, .Lfunc_end11-_draw_menu
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
	jr	nz, .LBB12_2
; %bb.1:
	ld	hl, _.str.12
	jr	.LBB12_4
	.local	.LBB12_2
.LBB12_2:
	push	de
	pop	hl
	ld	a, (hl)
	or	a, a
	ld	hl, _.str.12
	jr	z, .LBB12_4
; %bb.3:
	ex	de, hl
	.local	.LBB12_4
.LBB12_4:
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	call	_os_NewLine
	ld	hl, _.str.13
	push	hl
	call	_os_PutStrFull
	ld	sp, ix
	pop	ix
	jp	_wait_for_any_key
	.local	.Lfunc_end12
.Lfunc_end12:
	.size	_show_result, .Lfunc_end12-_show_result
                                        ; -- End function
	.section	.text._wait_for_any_key,"ax",@progbits
	.type	_wait_for_any_key,@function     ; -- Begin function wait_for_any_key
_wait_for_any_key:                      ; @wait_for_any_key
; %bb.0:
	.local	.LBB13_1
.LBB13_1:                               ; =>This Inner Loop Header: Depth=1
	call	_os_GetCSC
	or	a, a
	jr	nz, .LBB13_1
	.local	.LBB13_2
.LBB13_2:                               ; %.preheader
                                        ; =>This Inner Loop Header: Depth=1
	call	_os_GetCSC
	or	a, a
	jr	z, .LBB13_2
; %bb.3:
	ret
	.local	.Lfunc_end13
.Lfunc_end13:
	.size	_wait_for_any_key, .Lfunc_end13-_wait_for_any_key
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
	.asciz	"get|%s|%u"

	.section	.rodata._.str.1,"a",@progbits
	.balign	1
	.local	_.str.1
_.str.1:
	.asciz	"Timed out waiting for header."

	.section	.rodata._.str.2,"a",@progbits
	.balign	1
	.local	_.str.2
_.str.2:
	.asciz	"error|"

	.section	.rodata._.str.3,"a",@progbits
	.balign	1
	.local	_.str.3
_.str.3:
	.asciz	"Bad response header."

	.section	.rodata._.str.4,"a",@progbits
	.balign	1
	.local	_.str.4
_.str.4:
	.asciz	"Bad content length."

	.section	.rodata._.str.5,"a",@progbits
	.balign	1
	.local	_.str.5
_.str.5:
	.asciz	"=== CELinK DEMO ==="

	.section	.rodata._.str.1.6,"a",@progbits
	.balign	1
	.local	_.str.1.6
_.str.1.6:
	.asciz	"STATUS: CONNECTED"

	.section	.rodata._.str.2.7,"a",@progbits
	.balign	1
	.local	_.str.2.7
_.str.2.7:
	.asciz	"STATUS: WAITING..."

	.section	.rodata._.str.3.8,"a",@progbits
	.balign	1
	.local	_.str.3.8
_.str.3.8:
	.asciz	"1:Scan  2:Connect"

	.section	.rodata._.str.4.9,"a",@progbits
	.balign	1
	.local	_.str.4.9
_.str.4.9:
	.asciz	"3:Discon 4:Status"

	.section	.rodata._.str.5.10,"a",@progbits
	.balign	1
	.local	_.str.5.10
_.str.5.10:
	.asciz	"5:Ping  6:Help"

	.section	.rodata._.str.6,"a",@progbits
	.balign	1
	.local	_.str.6
_.str.6:
	.asciz	"7:Get"

	.section	.rodata._.str.7,"a",@progbits
	.balign	1
	.local	_.str.7
_.str.7:
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
	.asciz	"(no response)"

	.section	.rodata._.str.13,"a",@progbits
	.balign	1
	.local	_.str.13
_.str.13:
	.asciz	"Press any key..."

	.section	.rodata._.str.14,"a",@progbits
	.balign	1
	.local	_.str.14
_.str.14:
	.asciz	"CONNECT"

	.section	.rodata._.str.15,"a",@progbits
	.balign	1
	.local	_.str.15
_.str.15:
	.asciz	"SSID:"

	.section	.rodata._.str.16,"a",@progbits
	.balign	1
	.local	_.str.16
_.str.16:
	.asciz	"PASSWORD:"

	.section	.rodata._.str.17,"a",@progbits
	.balign	1
	.local	_.str.17
_.str.17:
	.asciz	"connect|%s|%s"

	.section	.rodata._.str.18,"a",@progbits
	.balign	1
	.local	_.str.18
_.str.18:
	.asciz	"Sent. Check status to confirm."

	.section	.rodata._.str.19,"a",@progbits
	.balign	1
	.local	_.str.19
_.str.19:
	.asciz	"Failed to send."

	.section	.rodata._.str.20,"a",@progbits
	.balign	1
	.local	_.str.20
_.str.20:
	.asciz	"DISCONNECT"

	.section	.rodata._.str.21,"a",@progbits
	.balign	1
	.local	_.str.21
_.str.21:
	.asciz	"disconnect"

	.section	.rodata._.str.22,"a",@progbits
	.balign	1
	.local	_.str.22
_.str.22:
	.asciz	"Sent."

	.section	.rodata._.str.23,"a",@progbits
	.balign	1
	.local	_.str.23
_.str.23:
	.asciz	"STATUS"

	.section	.rodata._.str.24,"a",@progbits
	.balign	1
	.local	_.str.24
_.str.24:
	.asciz	"wifiisconnected"

	.section	.rodata._.str.25,"a",@progbits
	.balign	1
	.local	_.str.25
_.str.25:
	.asciz	"PING"

	.section	.rodata._.str.26,"a",@progbits
	.balign	1
	.local	_.str.26
_.str.26:
	.asciz	"HOST/IP:"

	.section	.rodata._.str.27,"a",@progbits
	.balign	1
	.local	_.str.27
_.str.27:
	.asciz	"TIMEOUT(s):"

	.section	.rodata._.str.28,"a",@progbits
	.balign	1
	.local	_.str.28
_.str.28:
	.asciz	"ping|%s|%s"

	.section	.rodata._.str.29,"a",@progbits
	.balign	1
	.local	_.str.29
_.str.29:
	.asciz	"HELP"

	.section	.rodata._.str.30,"a",@progbits
	.balign	1
	.local	_.str.30
_.str.30:
	.asciz	"help"

	.section	.bss._run_get.body,"aw",@nobits
	.balign	1
	.local	_run_get.body
_run_get.body:
	.zero	2048

	.section	.rodata._.str.31,"a",@progbits
	.balign	1
	.local	_.str.31
_.str.31:
	.asciz	"GET"

	.section	.rodata._.str.32,"a",@progbits
	.balign	1
	.local	_.str.32
_.str.32:
	.asciz	"URL:"

	.section	.rodata._.str.33,"a",@progbits
	.balign	1
	.local	_.str.33
_.str.33:
	.asciz	"GET %d"

	.section	.rodata._.str.34,"a",@progbits
	.balign	1
	.local	_.str.34
_.str.34:
	.asciz	"GET FAILED (%d)"

	.section	.rodata._.str.35,"a",@progbits
	.balign	1
	.local	_.str.35
_.str.35:
	.asciz	"=== CELinK DEBUG ==="

	.section	.rodata._.str.36,"a",@progbits
	.balign	1
	.local	_.str.36
_.str.36:
	.asciz	"SERIAL: OPEN"

	.section	.rodata._.str.37,"a",@progbits
	.balign	1
	.local	_.str.37
_.str.37:
	.asciz	"SERIAL: CLOSED"

	.section	.rodata._.str.38,"a",@progbits
	.balign	1
	.local	_.str.38
_.str.38:
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
	.extern	_os_GetStringInput
	.extern	_llvm.eh.sjlj.lsda
	.extern	__Unwind_SjLj_Unregister
	.extern	_strlen
	.extern	__frameset
	.extern	_kb_Scan
	.extern	_atol
	.extern	_srl_UsbEventCallback
	.extern	_usb_Init
	.extern	__setflag
	.extern	_atoi
	.extern	_srl_Close
	.extern	_os_ClrLCD
	.extern	_os_GetCSC
	.extern	_llvm.eh.sjlj.setup.dispatch
	.extern	_llvm.stacksave.p0
	.extern	_llvm.eh.sjlj.callsite
	.extern	__lcmpzero
	.extern	_srl_Open
	.extern	_llvm.lifetime.start.p0
	.extern	_memcmp
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
	.extern	_usb_UnrefDevice
	.extern	_strchr
	.extern	_os_NewLine
	.extern	_srl_Read
