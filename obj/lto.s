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
	ld	(_message_ready), a
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
	ld	hl, -1
	call	__frameset
	ld	hl, (ix + 6)
	ld	bc, 0
	ld	de, 11
	or	a, a
	sbc	hl, de
	jp	nz, .LBB1_9
; %bb.1:
	ld	iy, (ix + 9)
	ld	hl, (_setup_seen)
	inc	hl
	ld	(_setup_seen), hl
	lea	hl, iy + 0
	add	hl, bc
	or	a, a
	sbc	hl, bc
	jp	z, .LBB1_9
; %bb.2:
	ld	a, (iy)
	ld	de, 0
	push	de
	pop	hl
	ld	l, a
	ld	(_last_bmRequestType), hl
	ld	c, (iy + 1)
	push	de
	pop	hl
	ld	(ix - 1), c                     ; 1-byte Folded Spill
	ld	l, c
	ld	(_last_bRequest), hl
	ld	hl, (iy + 2)
	push	de
	pop	bc
	ld	c, l
	ld	b, h
	ld	(_last_wValue), bc
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
	cp	a, 64
	jp	nz, .LBB1_8
; %bb.3:
	ld	a, (ix - 1)                     ; 1-byte Folded Reload
	cp	a, 1
	jp	nz, .LBB1_8
; %bb.4:
	ld	bc, 1
	ld.sis	de, 256
                                        ; kill: def $hl killed $hl killed $uhl
	or	a, a
	sbc.sis	hl, de
	jr	nc, .LBB1_9
; %bb.5:
	ld	a, (_transfer_pending)
	bit	0, a
	jr	nz, .LBB1_9
; %bb.6:
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
	jr	nz, .LBB1_10
; %bb.7:
	ld	hl, 5
	jr	.LBB1_12
	.local	.LBB1_8
.LBB1_8:
	ld	bc, 0
	.local	.LBB1_9
.LBB1_9:
	push	bc
	pop	hl
	inc	sp
	pop	ix
	ret
	.local	.LBB1_10
.LBB1_10:
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
	jr	nz, .LBB1_14
; %bb.11:
	ld	hl, 2
	.local	.LBB1_12
.LBB1_12:
	ld	(_last_status), hl
	.local	.LBB1_13
.LBB1_13:
	ld	bc, 1
	jr	.LBB1_9
	.local	.LBB1_14
.LBB1_14:
	ld	a, 1
	ld	iy, _message_buffer
	ld	bc, _celink_transfer_callback
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
	ex	de, hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	pop	hl
	sbc	hl, hl
	adc	hl, de
	jr	nz, .LBB1_16
; %bb.15:
	ld	hl, (_transfer_scheduled)
	inc	hl
	ld	(_transfer_scheduled), hl
	jr	.LBB1_13
	.local	.LBB1_16
.LBB1_16:
	xor	a, a
	ld	(_transfer_pending), a
	ld	(_schedule_error), de
	ld	(_last_status), de
	jr	.LBB1_13
	.local	.Lfunc_end1
.Lfunc_end1:
	.size	_celink_usb_event, .Lfunc_end1-_celink_usb_event
                                        ; -- End function
	.section	.text._celink_transfer_callback,"ax",@progbits
	.type	_celink_transfer_callback,@function ; -- Begin function celink_transfer_callback
_celink_transfer_callback:              ; @celink_transfer_callback
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
	.size	_celink_transfer_callback, .Lfunc_end2-_celink_transfer_callback
                                        ; -- End function
	.section	.text._celink_process,"ax",@progbits
	.globl	_celink_process                 ; -- Begin function celink_process
	.type	_celink_process,@function
_celink_process:                        ; @celink_process
; %bb.0:
	ld	a, (_usb_initialized)
	bit	0, a
	jr	z, .LBB3_2
; %bb.1:
	call	_usb_HandleEvents
	call	_usb_PollTransfers
	.local	.LBB3_2
.LBB3_2:
	ret
	.local	.Lfunc_end3
.Lfunc_end3:
	.size	_celink_process, .Lfunc_end3-_celink_process
                                        ; -- End function
	.section	.text._celink_message_available,"ax",@progbits
	.globl	_celink_message_available       ; -- Begin function celink_message_available
	.type	_celink_message_available,@function
_celink_message_available:              ; @celink_message_available
; %bb.0:
	ld	a, (_message_ready)
	ret
	.local	.Lfunc_end4
.Lfunc_end4:
	.size	_celink_message_available, .Lfunc_end4-_celink_message_available
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
	.local	.Lfunc_end5
.Lfunc_end5:
	.size	_celink_get_message, .Lfunc_end5-_celink_get_message
                                        ; -- End function
	.section	.text._celink_disconnect,"ax",@progbits
	.globl	_celink_disconnect              ; -- Begin function celink_disconnect
	.type	_celink_disconnect,@function
_celink_disconnect:                     ; @celink_disconnect
; %bb.0:
	ld	a, (_usb_initialized)
	bit	0, a
	jr	z, .LBB6_2
; %bb.1:
	call	_usb_Cleanup
	xor	a, a
	ld	(_usb_initialized), a
	ld	(_transfer_pending), a
	ld	(_message_ready), a
	ld	(_message_buffer), a
	.local	.LBB6_2
.LBB6_2:
	ret
	.local	.Lfunc_end6
.Lfunc_end6:
	.size	_celink_disconnect, .Lfunc_end6-_celink_disconnect
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
	.local	.LBB7_1
.LBB7_1:                                ; =>This Inner Loop Header: Depth=1
	call	_kb_Scan
	call	_celink_process
	ld	hl, (_setup_seen)
	ld	de, (ix - 30)
	or	a, a
	sbc	hl, de
	jp	z, .LBB7_3
; %bb.2:                                ;   in Loop: Header=BB7_1 Depth=1
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
	.local	.LBB7_3
.LBB7_3:                                ;   in Loop: Header=BB7_1 Depth=1
	ld	a, (_message_ready)
	bit	0, a
	jr	z, .LBB7_5
; %bb.4:                                ;   in Loop: Header=BB7_1 Depth=1
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
	.local	.LBB7_5
.LBB7_5:                                ;   in Loop: Header=BB7_1 Depth=1
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
	jp	z, .LBB7_1
; %bb.6:
	call	_celink_disconnect
	or	a, a
	sbc	hl, hl
	ld	sp, ix
	pop	ix
	ret
	.local	.Lfunc_end7
.Lfunc_end7:
	.size	_main, .Lfunc_end7-_main
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

	.section	.bss._message_ready,"aw",@nobits
	.balign	1
	.local	_message_ready
_message_ready:
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
	.asciz	"CLEAR = QUIT"

	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.section	".note.GNU-stack","",@progbits
	.extern	_os_HomeUp
	.extern	_llvm.umin.i24
	.extern	_os_ClrLCD
	.extern	_usb_Cleanup
	.extern	_llvm.eh.sjlj.functioncontext
	.extern	_llvm.memcpy.p0.p0.i24
	.extern	_usb_HandleEvents
	.extern	_llvm.eh.sjlj.setup.dispatch
	.extern	_llvm.eh.sjlj.callsite
	.extern	_llvm.stacksave.p0
	.extern	_llvm.lifetime.end.p0
	.extern	_memcpy
	.extern	_llvm.lifetime.start.p0
	.extern	_llvm.eh.sjlj.lsda
	.extern	__Unwind_SjLj_Register
	.extern	_llvm.frameaddress.p0
	.extern	_usb_GetDeviceEndpoint
	.extern	_os_DrawStatusBar
	.extern	__Unwind_SjLj_Unregister
	.extern	_os_PutStrFull
	.extern	_llvm.stackrestore.p0
	.extern	_usb_ScheduleControlTransfer
	.extern	_usb_PollTransfers
	.extern	__frameset
	.extern	_usb_FindDevice
	.extern	_kb_Scan
	.extern	_sprintf
	.extern	_usb_Init
	.extern	_os_NewLine
