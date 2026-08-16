	.section	.text,"ax",@progbits
	.assume	ADL = 1
	.file	"llvm-link"
	.section	.text._celink_init,"ax",@progbits
	.globl	_celink_init                    ; -- Begin function celink_init
	.type	_celink_init,@function
_celink_init:                           ; @celink_init
; %bb.0:
	xor	a, a
	ld	l, a
	ld	de, 0
	ld	iy, _celink_usb_event
	ld	bc, 36106
	ld	(_message_buffer), a
	ld	(_response_buffer), a
	ld	(_message_ready), a
	ld	(_response_pending), a
	ld	(_transfer_pending), a
	ld	a, l
	ld	(_usb_initialized), a
	ld	(_setup_seen), de
	ld	(_transfer_scheduled), de
	ld	(_transfer_completed), de
	ld	(_last_status), de
	ld	(_last_transferred), de
	ld	(_last_bmRequestType), de
	ld	(_last_bRequest), de
	ld	(_last_wValue), de
	ld	(_last_wIndex), de
	ld	(_last_wLength), de
	ld	(_schedule_error), de
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
	ld	(_last_status), de
	ret
	.local	.Lfunc_end0
.Lfunc_end0:
	.size	_celink_init, .Lfunc_end0-_celink_init
                                        ; -- End function
	.section	.text._celink_usb_event,"ax",@progbits
	.type	_celink_usb_event,@function     ; -- Begin function celink_usb_event
_celink_usb_event:                      ; @celink_usb_event
; %bb.0:
	ld	hl, -3
	call	__frameset
	ld	hl, (ix + 6)
	ld	bc, 0
	ld	de, 11
	or	a, a
	sbc	hl, de
	jr	nz, .LBB1_2
; %bb.1:
	ld	iy, (ix + 9)
	ld	hl, (_setup_seen)
	inc	hl
	ld	(_setup_seen), hl
	lea	hl, iy + 0
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB1_4
	.local	.LBB1_2
.LBB1_2:
	push	bc
	pop	hl
	.local	.LBB1_3
.LBB1_3:
	ld	sp, ix
	pop	ix
	ret
	.local	.LBB1_4
.LBB1_4:
	ld	a, (iy)
	ld	de, 0
	push	de
	pop	hl
	ld	l, a
	ld	(_last_bmRequestType), hl
	ld	c, (iy + 1)
	push	de
	pop	hl
	ld	(ix - 3), c                     ; 1-byte Folded Spill
	ld	l, c
	ld	(_last_bRequest), hl
	ld	bc, (iy + 2)
	push	de
	pop	hl
	ld	l, c
	ld	h, b
	ld	(_last_wValue), hl
	ld	hl, (iy + 4)
	push	de
	pop	bc
	ld	c, l
	ld	b, h
	ld	(_last_wIndex), bc
	ld	hl, (iy + 6)
	ld	e, l
	ld	d, h
	ld	(_last_wLength), de
	cp	a, -64
	jp	nz, .LBB1_17
; %bb.5:
	ld	a, (ix - 3)                     ; 1-byte Folded Reload
	cp	a, 2
	jp	nz, .LBB1_23
; %bb.6:
	ld	a, (_transfer_pending)
	bit	0, a
	jp	nz, .LBB1_27
; %bb.7:
	add.sis	hl, bc
	or	a, a
	sbc.sis	hl, bc
	jp	z, .LBB1_27
; %bb.8:
	ld	hl, 8
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	push	hl
	call	_usb_FindDevice
	ex	de, hl
	pop	hl
	pop	hl
	pop	hl
	sbc	hl, hl
	adc	hl, de
	jp	z, .LBB1_22
; %bb.9:
	or	a, a
	sbc	hl, hl
	push	hl
	push	de
	call	_usb_GetDeviceEndpoint
	ex	de, hl
	pop	hl
	pop	hl
	sbc	hl, hl
	adc	hl, de
	jp	z, .LBB1_25
; %bb.10:
	ld	bc, _celink_response_callback
	ld	a, (_response_pending)
	bit	0, a
	jp	z, .LBB1_28
; %bb.11:
	ld	(ix - 3), de
	ld	hl, _response_buffer
	push	hl
	call	_strlen
	ex	de, hl
	pop	hl
	ld	iy, (ix + 9)
	ld	hl, (iy + 6)
	ld	bc, 0
	ld	c, l
	ld	b, h
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	c, .LBB1_13
; %bb.12:
	push	bc
	pop	de
	.local	.LBB1_13
.LBB1_13:
	sbc	hl, hl
	adc	hl, de
	jp	z, .LBB1_27
; %bb.14:
	ld	bc, 255
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	jr	c, .LBB1_16
; %bb.15:
	ld	de, 255
	.local	.LBB1_16
.LBB1_16:
	ld	a, 1
	ld	(_transfer_pending), a
	or	a, a
	sbc	hl, hl
	push	hl
	ld	hl, _celink_response_callback
	push	hl
	push	de
	ld	hl, _response_buffer
	push	hl
	ld	hl, (ix - 3)
	push	hl
	jp	.LBB1_29
	.local	.LBB1_17
.LBB1_17:
	ld	e, (ix - 3)                     ; 1-byte Folded Reload
	cp	a, 64
	jp	nz, .LBB1_23
; %bb.18:
	ld	a, e
	cp	a, 1
	jp	nz, .LBB1_23
; %bb.19:
	ld.sis	de, 256
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	sbc.sis	hl, de
	jr	nc, .LBB1_27
; %bb.20:
	ld	a, (_transfer_pending)
	bit	0, a
	jr	nz, .LBB1_27
; %bb.21:
	ld	hl, 8
	push	hl
	or	a, a
	sbc	hl, hl
	push	hl
	push	hl
	call	_usb_FindDevice
	ex	de, hl
	pop	hl
	pop	hl
	pop	hl
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB1_24
	.local	.LBB1_22
.LBB1_22:
	ld	hl, 5
	jr	.LBB1_26
	.local	.LBB1_23
.LBB1_23:
	or	a, a
	sbc	hl, hl
	jp	.LBB1_3
	.local	.LBB1_24
.LBB1_24:
	or	a, a
	sbc	hl, hl
	push	hl
	push	de
	call	_usb_GetDeviceEndpoint
	ex	de, hl
	pop	hl
	pop	hl
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB1_30
	.local	.LBB1_25
.LBB1_25:
	ld	hl, 2
	.local	.LBB1_26
.LBB1_26:
	ld	(_last_status), hl
	.local	.LBB1_27
.LBB1_27:
	ld	hl, 1
	jp	.LBB1_3
	.local	.LBB1_28
.LBB1_28:
	ld	a, 1
	ld	(_transfer_pending), a
	or	a, a
	sbc	hl, hl
	push	hl
	push	bc
	push	hl
	push	hl
	push	de
	.local	.LBB1_29
.LBB1_29:
	call	_usb_ScheduleTransfer
	jr	.LBB1_31
	.local	.LBB1_30
.LBB1_30:
	ld	iy, _message_buffer
	ld	bc, _celink_receive_callback
	ld	a, 1
	ld	(_transfer_pending), a
	or	a, a
	sbc	hl, hl
	push	hl
	push	bc
	push	iy
	ld	hl, (ix + 9)
	push	hl
	push	de
	call	_usb_ScheduleControlTransfer
	.local	.LBB1_31
.LBB1_31:
	ex	de, hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB1_33
; %bb.32:
	ld	hl, (_transfer_scheduled)
	inc	hl
	ld	(_transfer_scheduled), hl
	jr	.LBB1_27
	.local	.LBB1_33
.LBB1_33:
	xor	a, a
	ld	(_transfer_pending), a
	ld	(_schedule_error), de
	ld	(_last_status), de
	jr	.LBB1_27
	.local	.Lfunc_end1
.Lfunc_end1:
	.size	_celink_usb_event, .Lfunc_end1-_celink_usb_event
                                        ; -- End function
	.section	.text._celink_receive_callback,"ax",@progbits
	.type	_celink_receive_callback,@function ; -- Begin function celink_receive_callback
_celink_receive_callback:               ; @celink_receive_callback
; %bb.0:
	ld	hl, -3
	call	__frameset
	ld	hl, (ix + 9)
	ld	de, (ix + 12)
	xor	a, a
	ld	iy, 0
	ld	(_transfer_pending), a
	ld	(_last_status), hl
	ld	(_last_transferred), de
	ld	bc, (_transfer_completed)
	inc	bc
	ld	(_transfer_completed), bc
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB2_7
; %bb.1:
	ld	bc, 255
	push	de
	pop	hl
	or	a, a
	sbc	hl, bc
	push	de
	pop	bc
	jr	c, .LBB2_3
; %bb.2:
	ld	bc, 255
	.local	.LBB2_3
.LBB2_3:
	ld	a, 1
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB2_6
; %bb.4:
	ld	de, (ix + 15)
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB2_6
; %bb.5:
	push	bc
	push	de
	ld	hl, _message_buffer
	push	hl
	ld	(ix - 3), bc
	call	_memcpy
	ld	a, 1
	ld	bc, (ix - 3)
	ld	iy, 0
	pop	hl
	pop	hl
	pop	hl
	.local	.LBB2_6
.LBB2_6:
	ld	hl, _message_buffer
	add	hl, bc
	ld	(hl), 0
	ld	(_message_ready), a
	.local	.LBB2_7
.LBB2_7:
	lea	hl, iy + 0
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end2
.Lfunc_end2:
	.size	_celink_receive_callback, .Lfunc_end2-_celink_receive_callback
                                        ; -- End function
	.section	.text._celink_response_callback,"ax",@progbits
	.type	_celink_response_callback,@function ; -- Begin function celink_response_callback
_celink_response_callback:              ; @celink_response_callback
; %bb.0:
	call	__frameset0
	ld	hl, (ix + 9)
	ld	bc, (ix + 12)
	xor	a, a
	ld	de, 0
	ld	(_transfer_pending), a
	ld	(_last_status), hl
	ld	(_last_transferred), bc
	ld	bc, (_transfer_completed)
	inc	bc
	ld	(_transfer_completed), bc
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jr	nz, .LBB3_2
; %bb.1:
	ld	(_response_pending), a
	ld	(_response_buffer), a
	.local	.LBB3_2
.LBB3_2:
	ex	de, hl
	pop	ix
	ret
	.local	.Lfunc_end3
.Lfunc_end3:
	.size	_celink_response_callback, .Lfunc_end3-_celink_response_callback
                                        ; -- End function
	.section	.text._celink_process,"ax",@progbits
	.globl	_celink_process                 ; -- Begin function celink_process
	.type	_celink_process,@function
_celink_process:                        ; @celink_process
; %bb.0:
	ld	a, (_usb_initialized)
	bit	0, a
	jr	z, .LBB4_2
; %bb.1:
	call	_usb_HandleEvents
	call	_usb_PollTransfers
	.local	.LBB4_2
.LBB4_2:
	ret
	.local	.Lfunc_end4
.Lfunc_end4:
	.size	_celink_process, .Lfunc_end4-_celink_process
                                        ; -- End function
	.section	.text._celink_message_available,"ax",@progbits
	.globl	_celink_message_available       ; -- Begin function celink_message_available
	.type	_celink_message_available,@function
_celink_message_available:              ; @celink_message_available
; %bb.0:
	ld	a, (_message_ready)
	ret
	.local	.Lfunc_end5
.Lfunc_end5:
	.size	_celink_message_available, .Lfunc_end5-_celink_message_available
                                        ; -- End function
	.section	.text._celink_get_message,"ax",@progbits
	.globl	_celink_get_message             ; -- Begin function celink_get_message
	.type	_celink_get_message,@function
_celink_get_message:                    ; @celink_get_message
; %bb.0:
	xor	a, a
	ld	hl, _message_buffer
	ld	(_message_ready), a
	ret
	.local	.Lfunc_end6
.Lfunc_end6:
	.size	_celink_get_message, .Lfunc_end6-_celink_get_message
                                        ; -- End function
	.section	.text._celink_response_pending,"ax",@progbits
	.globl	_celink_response_pending        ; -- Begin function celink_response_pending
	.type	_celink_response_pending,@function
_celink_response_pending:               ; @celink_response_pending
; %bb.0:
	ld	a, (_response_pending)
	ret
	.local	.Lfunc_end7
.Lfunc_end7:
	.size	_celink_response_pending, .Lfunc_end7-_celink_response_pending
                                        ; -- End function
	.section	.text._celink_send,"ax",@progbits
	.globl	_celink_send                    ; -- Begin function celink_send
	.type	_celink_send,@function
_celink_send:                           ; @celink_send
; %bb.0:
	ld	hl, -3
	call	__frameset
	ld	de, (ix + 6)
	xor	a, a
	sbc	hl, hl
	adc	hl, de
	jr	z, .LBB8_4
; %bb.1:
	push	de
	call	_strlen
	push	hl
	pop	bc
	pop	hl
	push	bc
	pop	hl
	ld	de, -256
	add	hl, de
	inc	de
	or	a, a
	sbc	hl, de
	jr	c, .LBB8_3
; %bb.2:
	ld	a, (_response_pending)
	bit	0, a
	jr	z, .LBB8_5
	.local	.LBB8_3
.LBB8_3:
	xor	a, a
	.local	.LBB8_4
.LBB8_4:
	pop	hl
	pop	ix
	ret
	.local	.LBB8_5
.LBB8_5:
	ld	a, (_transfer_pending)
	bit	0, a
	ld	a, 0
	jr	nz, .LBB8_4
; %bb.6:
	ld	de, _response_buffer
	push	bc
	ld	hl, (ix + 6)
	push	hl
	push	de
	ld	(ix - 3), bc
	call	_memcpy
	ld	a, 1
	pop	hl
	pop	hl
	pop	hl
	ld	hl, _response_buffer
	ld	de, (ix - 3)
	add	hl, de
	ld	(hl), 0
	ld	(_response_pending), a
	jr	.LBB8_4
	.local	.Lfunc_end8
.Lfunc_end8:
	.size	_celink_send, .Lfunc_end8-_celink_send
                                        ; -- End function
	.section	.text._celink_disconnect,"ax",@progbits
	.globl	_celink_disconnect              ; -- Begin function celink_disconnect
	.type	_celink_disconnect,@function
_celink_disconnect:                     ; @celink_disconnect
; %bb.0:
	ld	a, (_usb_initialized)
	bit	0, a
	jr	z, .LBB9_2
; %bb.1:
	call	_usb_Cleanup
	xor	a, a
	ld	(_usb_initialized), a
	ld	(_transfer_pending), a
	ld	(_message_ready), a
	ld	(_response_pending), a
	ld	(_message_buffer), a
	ld	(_response_buffer), a
	.local	.LBB9_2
.LBB9_2:
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
	ld	hl, -30
	call	__frameset
	scf
	sbc	hl, hl
	ld	(ix - 30), hl
	lea	hl, ix - 24
	ld	(ix - 27), hl
	ld	iy, -3145600
	call	_os_ClrLCD
	call	_os_HomeUp
	call	_os_DrawStatusBar
	call	_celink_init
	.local	.LBB10_1
.LBB10_1:                               ; =>This Inner Loop Header: Depth=1
	call	_kb_Scan
	call	_celink_process
	ld	hl, (_setup_seen)
	ld	de, (ix - 30)
	or	a, a
	sbc	hl, de
	jp	z, .LBB10_3
; %bb.2:                                ;   in Loop: Header=BB10_1 Depth=1
	ld	hl, (_setup_seen)
	ld	(ix - 30), hl
	ld	hl, -3145600
	push	hl
	pop	iy
	call	_os_ClrLCD
	ld	iy, -3145600
	call	_os_HomeUp
	call	_os_DrawStatusBar
	ld	hl, _.str
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	ld	hl, (_setup_seen)
	push	hl
	ld	hl, _.str.1
	push	hl
	ld	hl, (ix - 27)
	push	hl
	call	_sprintf
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 27)
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	ld	hl, (_last_bmRequestType)
	ld	de, (_last_bRequest)
	push	de
	push	hl
	ld	hl, _.str.2
	push	hl
	ld	hl, (ix - 27)
	push	hl
	call	_sprintf
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 27)
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	ld	hl, (_last_wLength)
	push	hl
	ld	hl, _.str.3
	push	hl
	ld	hl, (ix - 27)
	push	hl
	call	_sprintf
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 27)
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	ld	hl, (_transfer_scheduled)
	ld	de, (_transfer_completed)
	push	de
	push	hl
	ld	hl, _.str.4
	push	hl
	ld	hl, (ix - 27)
	push	hl
	call	_sprintf
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 27)
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	ld	hl, (_last_status)
	push	hl
	ld	hl, _.str.5
	push	hl
	ld	hl, (ix - 27)
	push	hl
	call	_sprintf
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 27)
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	ld	hl, (_last_transferred)
	push	hl
	ld	hl, _.str.6
	push	hl
	ld	hl, (ix - 27)
	push	hl
	call	_sprintf
	pop	hl
	pop	hl
	pop	hl
	ld	hl, (ix - 27)
	push	hl
	call	_os_PutStrFull
	pop	hl
	.local	.LBB10_3
.LBB10_3:                               ;   in Loop: Header=BB10_1 Depth=1
	ld	a, (_message_ready)
	bit	0, a
	jr	z, .LBB10_5
; %bb.4:                                ;   in Loop: Header=BB10_1 Depth=1
	xor	a, a
	ld	(_message_ready), a
	ld	hl, -3145600
	push	hl
	pop	iy
	call	_os_ClrLCD
	ld	iy, -3145600
	call	_os_HomeUp
	call	_os_DrawStatusBar
	ld	hl, _.str.7
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	call	_os_NewLine
	ld	hl, _message_buffer
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	call	_os_NewLine
	ld	hl, _.str.8
	push	hl
	call	_os_PutStrFull
	pop	hl
	.local	.LBB10_5
.LBB10_5:                               ;   in Loop: Header=BB10_1 Depth=1
	ld	hl, -720868
	push	de
	ld	e, (hl)
	inc	hl
	ld	d, (hl)
	ld	l, e
	ld	h, d
	pop	de
	ld.sis	bc, 1
	call	__sand
	bit	0, l
	jr	z, .LBB10_8
; %bb.6:                                ;   in Loop: Header=BB10_1 Depth=1
	ld	hl, _.str.9
	push	hl
	call	_celink_send
	pop	hl
	bit	0, a
	jr	z, .LBB10_8
; %bb.7:                                ;   in Loop: Header=BB10_1 Depth=1
	ld	hl, -3145600
	push	hl
	pop	iy
	call	_os_ClrLCD
	ld	iy, -3145600
	call	_os_HomeUp
	call	_os_DrawStatusBar
	ld	hl, _.str.10
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	call	_os_NewLine
	ld	hl, _.str.11
	push	hl
	call	_os_PutStrFull
	pop	hl
	.local	.LBB10_8
.LBB10_8:                               ;   in Loop: Header=BB10_1 Depth=1
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
	jp	z, .LBB10_1
; %bb.9:
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
	.section	.bss._last_wValue,"aw",@nobits
	.balign	1
	.globl	_last_wValue
_last_wValue:
	.zero	3

	.section	.bss._last_wIndex,"aw",@nobits
	.balign	1
	.globl	_last_wIndex
_last_wIndex:
	.zero	3

	.section	.bss._schedule_error,"aw",@nobits
	.balign	1
	.globl	_schedule_error
_schedule_error:
	.zero	3

	.section	.bss._message_buffer,"aw",@nobits
	.balign	1
	.local	_message_buffer
_message_buffer:
	.zero	256

	.section	.bss._response_buffer,"aw",@nobits
	.balign	1
	.local	_response_buffer
_response_buffer:
	.zero	256

	.section	.bss._message_ready,"aw",@nobits
	.balign	1
	.local	_message_ready
_message_ready:
	.zero	1

	.section	.bss._response_pending,"aw",@nobits
	.balign	1
	.local	_response_pending
_response_pending:
	.zero	1

	.section	.bss._transfer_pending,"aw",@nobits
	.balign	1
	.local	_transfer_pending
_transfer_pending:
	.zero	1

	.section	.bss._usb_initialized,"aw",@nobits
	.balign	1
	.local	_usb_initialized
_usb_initialized:
	.zero	1

	.section	.bss._setup_seen,"aw",@nobits
	.balign	1
	.globl	_setup_seen
_setup_seen:
	.zero	3

	.section	.rodata._.str,"a",@progbits
	.balign	1
	.local	_.str
_.str:
	.asciz	"CELinK DEBUG"

	.section	.rodata._.str.1,"a",@progbits
	.balign	1
	.local	_.str.1
_.str.1:
	.asciz	"SETUP %u"

	.section	.rodata._.str.2,"a",@progbits
	.balign	1
	.local	_.str.2
_.str.2:
	.asciz	"TYPE %02X REQ %02X"

	.section	.bss._last_bmRequestType,"aw",@nobits
	.balign	1
	.globl	_last_bmRequestType
_last_bmRequestType:
	.zero	3

	.section	.bss._last_bRequest,"aw",@nobits
	.balign	1
	.globl	_last_bRequest
_last_bRequest:
	.zero	3

	.section	.rodata._.str.3,"a",@progbits
	.balign	1
	.local	_.str.3
_.str.3:
	.asciz	"LEN %u"

	.section	.bss._last_wLength,"aw",@nobits
	.balign	1
	.globl	_last_wLength
_last_wLength:
	.zero	3

	.section	.rodata._.str.4,"a",@progbits
	.balign	1
	.local	_.str.4
_.str.4:
	.asciz	"SCHED %u DONE %u"

	.section	.bss._transfer_scheduled,"aw",@nobits
	.balign	1
	.globl	_transfer_scheduled
_transfer_scheduled:
	.zero	3

	.section	.bss._transfer_completed,"aw",@nobits
	.balign	1
	.globl	_transfer_completed
_transfer_completed:
	.zero	3

	.section	.rodata._.str.5,"a",@progbits
	.balign	1
	.local	_.str.5
_.str.5:
	.asciz	"STAT %u"

	.section	.bss._last_status,"aw",@nobits
	.balign	1
	.globl	_last_status
_last_status:
	.zero	3

	.section	.rodata._.str.6,"a",@progbits
	.balign	1
	.local	_.str.6
_.str.6:
	.asciz	"BYTES %u"

	.section	.bss._last_transferred,"aw",@nobits
	.balign	1
	.globl	_last_transferred
_last_transferred:
	.zero	3

	.section	.rodata._.str.7,"a",@progbits
	.balign	1
	.local	_.str.7
_.str.7:
	.asciz	"PC SAYS:"

	.section	.rodata._.str.8,"a",@progbits
	.balign	1
	.local	_.str.8
_.str.8:
	.asciz	"ENTER = REPLY"

	.section	.rodata._.str.9,"a",@progbits
	.balign	1
	.local	_.str.9
_.str.9:
	.asciz	"hello from CELinK"

	.section	.rodata._.str.10,"a",@progbits
	.balign	1
	.local	_.str.10
_.str.10:
	.asciz	"REPLY QUEUED"

	.section	.rodata._.str.11,"a",@progbits
	.balign	1
	.local	_.str.11
_.str.11:
	.asciz	"Waiting for PC..."

	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.section	".note.GNU-stack","",@progbits
	.extern	_os_HomeUp
	.extern	_llvm.umin.i24
	.extern	_usb_Cleanup
	.extern	_llvm.eh.sjlj.functioncontext
	.extern	_usb_HandleEvents
	.extern	_llvm.lifetime.end.p0
	.extern	_memcpy
	.extern	_llvm.eh.sjlj.lsda
	.extern	_usb_GetDeviceEndpoint
	.extern	__Unwind_SjLj_Unregister
	.extern	_strlen
	.extern	_usb_ScheduleControlTransfer
	.extern	__frameset
	.extern	_usb_PollTransfers
	.extern	_usb_FindDevice
	.extern	_kb_Scan
	.extern	_usb_Init
	.extern	_usb_ScheduleTransfer
	.extern	_os_ClrLCD
	.extern	_llvm.memcpy.p0.p0.i24
	.extern	_llvm.eh.sjlj.callsite
	.extern	_llvm.eh.sjlj.setup.dispatch
	.extern	_llvm.stacksave.p0
	.extern	_llvm.lifetime.start.p0
	.extern	__frameset0
	.extern	__Unwind_SjLj_Register
	.extern	_llvm.frameaddress.p0
	.extern	_os_DrawStatusBar
	.extern	_os_PutStrFull
	.extern	__sand
	.extern	_llvm.stackrestore.p0
	.extern	_sprintf
	.extern	_os_NewLine
