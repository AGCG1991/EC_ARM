	.include "configuration.inc" 
	.include "inter.inc"

	mov     r0, #0b11010011
	msr     cpsr_c, r0
	mov     sp, #0x8000000

	exit: b exit