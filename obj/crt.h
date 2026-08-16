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
	.global _usb_PollTransfers
	.type _usb_PollTransfers, @function
_usb_PollTransfers:
	jp 6
	.global _usb_HandleEvents
	.type _usb_HandleEvents, @function
_usb_HandleEvents:
	jp 9
	.global _usb_FindDevice
	.type _usb_FindDevice, @function
_usb_FindDevice:
	jp 36
	.global _usb_GetDeviceEndpoint
	.type _usb_GetDeviceEndpoint, @function
_usb_GetDeviceEndpoint:
	jp 84
	.global _usb_ScheduleControlTransfer
	.type _usb_ScheduleControlTransfer, @function
_usb_ScheduleControlTransfer:
	jp 126
	.global _usb_ScheduleTransfer
	.type _usb_ScheduleTransfer, @function
_usb_ScheduleTransfer:
	jp 129
.endm
#endif
#define HAS_LIBLOAD 1
