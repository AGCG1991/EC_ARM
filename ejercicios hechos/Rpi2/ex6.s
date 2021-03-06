.include "configuration.inc" 
	.include "inter.inc"
	
	mov r0,#0
	ADDEXC 0x1C, fast_interrupt

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
	   ldr r0, =STBASE
	   ldr r1, [r0, #STCLO] 
	   add   r1, #500
	   str r1, [r0, #STC3]
	
	   ldr r0,  =INTBASE
	   ldr    r1, =0x083 
	   str r1, [r0, #INTFIQCON]
	
	    mov r1, #0b10010011 
	    msr cpsr_c, r1   
	
	   mov r6, #0
	
x : b x

fast_interrupt: 
	push {r0-r5}
	ldr r3, =0x3F20001C
	ldr r4, =0x3F200028
	ldr r5, =0x010
	
	 eors r6, #1
	 streq r5, [r4]
	 strne r5, [r3]
	
	
	 ldr r0, =STBASE
	 ldr r1, [r0, #STCLO] 
	 add   r1, #500
         str r1, [r0, #STC3]
	
	ldr r0, =STBASE
	mov r1, #0b01000
	str r1, [r0,#STCS]
	
	pop {r0-r5}
	subs pc, lr, #4
	