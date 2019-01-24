	.include "configuration.inc" 
	.include "inter.inc"
	
	mov     r0, #0b11010001
	msr     cpsr_c, r0
	mov     sp, #0x4000        
	
	exit: b exit
