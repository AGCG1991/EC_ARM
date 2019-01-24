	.include "configuration.inc" 
	.include "inter.inc"
	
	mov r0,#0
	ADDEXC 0x18, regular_interrupt

	/* IRQ mode*/   
	mov r0, #0b11010010    
	msr cpsr_c, r0
	mov sp, #0x8000 
	
	/* FIQ mode*/   
	mov r0, #0b11010001 
	msr cpsr_c, r0
	mov sp, #0x4000 
	
	/*  SVC mode*/ 
	mov r0, #0b11010011 
	msr cpsr_c, r0
	mov sp, #0x8000000 

main: 
	ldr r0, =INTBASE 
	ldr r1,  =0x00100000 
	str r1,[r0,#INTENIRQ2] 
	
	 ldr r0, =GPBASE 
	mov r1, #0b01100 
	str r1,[r0,#GPFEN0] 
	
	mov r1, #0b01010011 
	msr cpsr_c, r1

x: b x

regular_interrupt: 
	
	ldr r0, =0x3F20001C // Encender
	mov r1, #0x800
	str r1, [r0]
	
	 ldr r0, =GPBASE 
	 mov r1, #0b01100 
	 str r1,[r0,#GPEDS0]
	 subs pc, lr , #4 