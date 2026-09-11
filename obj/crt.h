/* generated from: obj/CELINK.o */
#define HAS_INIT_ARRAY 0
#define HAS_FINI_ARRAY 0
#define HAS_CLOCK 0
#define HAS_ABORT 0
#define HAS_EXIT 0
#define HAS_C99__EXIT 0
#define HAS_RUN_PRGM 0
#define HAS_MAIN_ARGC_ARGV 0
#define HAS_ATEXIT 0
#ifdef __ASSEMBLER__
.macro LIBLOAD_LIBS
	.global __libload_library_KEYPADC
	.type __libload_library_KEYPADC, @object
__libload_library_KEYPADC:
	.db 0xC0, "KEYPADC", 0, 2
	.global _kb_Scan
	.type _kb_Scan, @function
_kb_Scan:
	jp 0
	.global __libload_library_SRLDRVCE
	.type __libload_library_SRLDRVCE, @object
__libload_library_SRLDRVCE:
	.db 0xC0, "SRLDRVCE", 0, 0
	.global _srl_Open
	.type _srl_Open, @function
_srl_Open:
	jp 0
	.global _srl_Close
	.type _srl_Close, @function
_srl_Close:
	jp 3
	.global _srl_Read
	.type _srl_Read, @function
_srl_Read:
	jp 6
	.global _srl_Write
	.type _srl_Write, @function
_srl_Write:
	jp 9
	.global _srl_UsbEventCallback
	.type _srl_UsbEventCallback, @function
_srl_UsbEventCallback:
	jp 15
	.global __libload_library_USBDRVCE
	.type __libload_library_USBDRVCE, @object
__libload_library_USBDRVCE:
	.db 0xC0, "USBDRVCE", 0, 0
	.global _usb_Init
	.type _usb_Init, @function
_usb_Init:
	jp 0
	.global _usb_Cleanup
	.type _usb_Cleanup, @function
_usb_Cleanup:
	jp 3
	.global _usb_HandleEvents
	.type _usb_HandleEvents, @function
_usb_HandleEvents:
	jp 9
	.global _usb_RefDevice
	.type _usb_RefDevice, @function
_usb_RefDevice:
	jp 18
	.global _usb_UnrefDevice
	.type _usb_UnrefDevice, @function
_usb_UnrefDevice:
	jp 21
	.global _usb_ResetDevice
	.type _usb_ResetDevice, @function
_usb_ResetDevice:
	jp 39
	.global _usb_GetRole
	.type _usb_GetRole, @function
_usb_GetRole:
	jp 114
.endm
#endif
#define HAS_LIBLOAD 1
