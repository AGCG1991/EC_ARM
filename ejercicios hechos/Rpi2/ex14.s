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
	
	ldr r6, =0x200
	mov r7, #2
	ldr r8, =0x20000
	mov r9, #20
	mov r11, #0
	
	ldr r3, =0x3F20001C
	ldr r4, =0x3F200028
	ldr r6,=0x100
	ldr r7, =2
	ldr r8, =0x1000
	ldr r9, =0x20
	
main: 
	ldr r0, =STBASE
	ldr r1, [r0, #STCLO]
	ldr r10, =1000000
	add   r1, r10
	str r1, [r0, #STC1]
	
	ldr r0,=INTBASE
	mov r1, #0b0010 
	str r1,[r0,#INTENIRQ1]
	
	mov r1, #0b01010011 
	msr cpsr_c, r1
	
x:	b x

regular_interrupt: 
	push {r0,r1, lr}
	
	cmp r6, #0x400
	blle first
	blgt last
	
	ldr r0, =STBASE
	ldr r1, [r0, #STCLO] 
	add   r1, r10
	str r1, [r0, #STC1]
	
	ldr r0, =STBASE
	mov r1, #0b0010
	str r1, [r0,#STCS]
	
	pop {r0,r1, lr}
	subs pc, lr, #4
	
first:
	cmp r6, #0x100
	strne r6, [r4]
	ldreq r5, =0x8000000
	streq r5, [r4]
	ldreq r8, =0x1000
	
	mul r5, r6, r7
	mov r6,  r5
	str r6, [r3]
	
	add lr,lr,#4
	
	bx lr

last:
	cmp r8, #0x1000
	strne r8, [r4]
	ldreq r5, =0x800
	streq r5, [r4]
	cmp r8, #0x8000000
	ldreq r6, =0x100
	
	mul r5, r8, r9
	mov r8, r5
	str r8, [r3]
	
	bx lr
	