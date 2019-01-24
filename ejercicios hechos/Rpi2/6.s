.include "configuration.inc" 
 	ldr  r0, =0x3F20001C  	/*r0 contents the port address for ON */
	ldr r2, =0x3F200028		/*leds off */
	ldr  r1, =0x400000
	ldr r6, =0x2
	ldr r7, =125000
inf:	ldr r8, =1000000

loop:	str  r1,[r0]
	bl wait
	str r1,[r2]
	bl wait	
	cmp r8, r7
	beq inf
	udiv r8, r8, r6
	b loop

wait:	ldr r4, =0x3F003004		/*timer*/
	ldr r3,[r4]
	mov r5, r8 
	add r5, r3, r5
ret1:ldr r3, [r4]
	cmp r3, r5
	blt ret1
	bx lr

