	.section	.text,"ax",@progbits
	.assume	ADL = 1
	.file	"llvm-link"
	.section	.text._celink_init,"ax",@progbits
	.globl	_celink_init                    ; -- Begin function celink_init
	.type	_celink_init,@function
_celink_init:                           ; @celink_init
; %bb.0:
	ret
	.local	.Lfunc_end0
.Lfunc_end0:
	.size	_celink_init, .Lfunc_end0-_celink_init
                                        ; -- End function
	.section	.text._celink_disconnect,"ax",@progbits
	.globl	_celink_disconnect              ; -- Begin function celink_disconnect
	.type	_celink_disconnect,@function
_celink_disconnect:                     ; @celink_disconnect
; %bb.0:
	ret
	.local	.Lfunc_end1
.Lfunc_end1:
	.size	_celink_disconnect, .Lfunc_end1-_celink_disconnect
                                        ; -- End function
	.section	.text._main,"ax",@progbits
	.globl	_main                           ; -- Begin function main
	.type	_main,@function
_main:                                  ; @main
; %bb.0:
	ld	iy, -3145600
	call	_os_ClrLCD
	call	_os_HomeUp
	call	_os_DrawStatusBar
	ld	hl, _.str
	push	hl
	call	_os_PutStrFull
	pop	hl
	ld	iy, -3145600
	call	_os_NewLine
	ld	hl, _.str.1
	push	hl
	call	_os_PutStrFull
	pop	hl
	.local	.LBB2_1
.LBB2_1:                                ; =>This Inner Loop Header: Depth=1
	call	_kb_Scan
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
	jr	z, .LBB2_1
; %bb.2:
	or	a, a
	sbc	hl, hl
	ret
	.local	.Lfunc_end2
.Lfunc_end2:
	.size	_main, .Lfunc_end2-_main
                                        ; -- End function
	.section	.rodata._.str,"a",@progbits
	.balign	1
	.local	_.str
_.str:
	.asciz	"CELinK says hi!"

	.section	.rodata._.str.1,"a",@progbits
	.balign	1
	.local	_.str.1
_.str.1:
	.asciz	"Press CLEAR to quit."

	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.ident	"clang version 19.1.0 (https://github.com/CE-Programming/llvm-project ef28e9c54cd1333a6091ab2ffbd315b465fc5090)"
	.section	".note.GNU-stack","",@progbits
	.extern	__Unwind_SjLj_Unregister
	.extern	_os_HomeUp
	.extern	_os_PutStrFull
	.extern	_os_ClrLCD
	.extern	_llvm.stackrestore.p0
	.extern	_llvm.eh.sjlj.functioncontext
	.extern	_llvm.eh.sjlj.setup.dispatch
	.extern	_llvm.eh.sjlj.callsite
	.extern	_llvm.stacksave.p0
	.extern	_kb_Scan
	.extern	_llvm.eh.sjlj.lsda
	.extern	_os_NewLine
	.extern	_os_DrawStatusBar
	.extern	__Unwind_SjLj_Register
	.extern	_llvm.frameaddress.p0
