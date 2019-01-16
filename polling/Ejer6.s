.include "inter.inc"

/* Los pulsadores estan en los GPIOS 2 y 3*/
.text
	
	mov	r0, #0b11010011
	msr	cpsr_c, r0
	mov	sp, #0x8000 @ init stack in SVC mode
	ldr	r0, =STBASE @ stack
	
        ldr     r1, =GPBASE @ gpio offset
/* guia bits           xx999888777666555444333222111000*/
        ldr   	r2, =0b00001000000000000001000000000000
        str	r2, [r1, #GPFSEL0]  @ Configura led amarillo GPIO 9 y speaker 4
/* guia bits           xx999888777666555444333222111000*/	
	ldr	r3, =0b00000000001000000000000000000000
	str	r3, [r1, #GPFSEL1] @ configura led rojo GPIO 17
	
/* guia bits           10987654321098765432109876543210*/
        ldr   	r6, =0b00000000000000000000001000000000 @ gpio 9
	ldr	r7, =0b00000000000000100000000000000000 @ gpio 17
        ldr   	r8, =0b00000000000000000000000000010000 @ speaker 4

bucle:	
	ldr	r4, [r1, #GPLEV0]
	/* guia bits   10987654321098765432109876543210*/
	tst	r4, #0b00000000000000000000000000000100
	beq	pulsador1
	/* guia bits   10987654321098765432109876543210*/	
	tst	r4, #0b00000000000000000000000000001000
	beq	pulsador2
	str	r6, [r1, #GPCLR0] @ apagar los leds por defecto
	str	r7, [r1, #GPCLR0]
	b 	bucle
	
pulsador1:
	str	r6, [r1, #GPSET0]
	ldr	r9, =1278		@ cambiar freq
	bl	espera			@ Salta a la rutina de espera
	str	r8, [r1, #GPSET0]	@ enciende speaker
	bl	espera			@ Salta a la rutina de espera
	str	r8, [r1, #GPCLR0]	@ apaga speaker
	b	bucle
	
pulsador2:
	str	r7, [r1, #GPSET0]
	ldr	r9, =955		@ cambiar freq
	bl	espera			@ Salta a la rutina de espera
	str	r8, [r1, #GPSET0]	@ enciende speaker
	bl	espera			@ Salta a la rutina de espera
	str	r8, [r1, #GPCLR0]	@ apaga speaker
	b	bucle
	

espera:	push 	{r10, r11}		@ Save r5 and r6 in the stack
	ldr	r10, [r0, #STCLO]	@ Load CLO Timer
	add	r10, r9			@ Add waiting time -> this is our ending time
ret1:	ldr	r11, [r0, #STCLO]
	cmp	r11, r10
	blo	ret1			@ If lower, go back to read timer again
	pop	{r10, r11}		@ Restore r5 and r6
	bx	lr			@ Return from routine

