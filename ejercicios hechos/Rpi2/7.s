.include "configuration.inc" 
 	ldr  r0, =0x3F20001C  	/*r0 contents the port address for ON */
	ldr r2, =0x3F200028		/*leds off */
	ldr r1, =0x08420E00		/*all leds */
	str r1, [r0]
	
	ldr r3, =0x3F200034		/*button*/
	ldr r5, =0x200
	ldr r6, =0x640
	
	ldr r7, =0x2
	ldr r8, =0x14
	ldr r9, =0x7A1200
	
loop:ldr r4, [r3]
	tst r4, #0b00100
	beq off

off: cmp r5, r6
	bge off2
	str r5, [r2]
	mul r2, r2, r7
	b loop
	
off2:str r6, [r2]
	mul r6, r6, r8
	cmp r6, r9
	beq end
	b loop
	
end: b end