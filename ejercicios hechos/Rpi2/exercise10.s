.include "configuration.inc"
	
	ldr r0, =0x3F20001C // Encender
	ldr r2, =0x3F200028 //Apagar
	ldr r3, =0x3F200034 //Boton
	
	sonido:
		ldr r1, =0x010
		str r1,[r0]
		bl wait
		ldr r1, =0x010
		str r1,[r2]
		bl wait
		ldr r8, [r3]
		tst r8, #0b00100
		bleq onLights
		ldr r8, [r3]
		tst r8, #0b001000
		beq end
		b sonido
	wait:
		ldr r5, =769
	loop2:
		subs r5, #1
		bne loop2
		bx lr
	
	onLights:
		ldr  r4, =0x08420E00		
		str  r4,[r0]
		bx lr
	
	end:	ldr  r4, =0x08420E00		
		str  r4,[r0]
		
	end1:	b end1
	