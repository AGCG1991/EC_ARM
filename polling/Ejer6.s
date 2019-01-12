.include "inter.inc"

/* Los pulsadores estan en los GPIOS 2 y 3*/
.text
	mov	r0, #0b11010011
	msr	cpsr_c, r0
	mov	sp, #0x8000
	
        ldr     r4, =GPBASE
/* guia bits           xx999888777666555444333222111000*/
        ldr   	r5, =0b00001000000000000001000000000000
        str	r5, [r4, #GPFSEL0]  @ Configura GPIO 4, 9 (SPEAKER, L Rojo)
		
/* guia bits           xx999888777666555444333222111000*/
        ldr   	r5, =0b00000000001000000000000000000000
        str	r5, [r4, #GPFSEL1]  @ Configura GPIO 17 (Led Amarillo)
	
/* guia bits           10987654321098765432109876543210*/
        ldr   	r5, =0b00000000000000000000000000010000 @ Speaker
	ldr	r6, =0b00000000000000000000001000000000 @ Led Rojo
	ldr	r7, =0b00000000000000100000000000000000 @ Led Amarillo
	
	ldr	r0, =STBASE
	ldr	r1, =1908 @ frecuencia 262Hz
	ldr	r2, =1278 @ frecuencia 391Hz

bucle:
	/*str	r5, [r4, #GPCLR0]	@ apaga speaker
	str	r6, [r4, #GPCLR0]	@ apaga led rojo
	str	r7, [r4, #GPCLR0]	@ apaga led amarillo*/
	
	ldr	r5, [r4, #GPLEV0]	@ direccion pulsador
	/* guia bits   10987654321098765432109876543210*/
	tst	r5, #0b00000000000000000000000000000100
	beq	pulsador1
	b	pulsador1
	/* guia bits   10987654321098765432109876543210*/	
	tst	r5, #0b00000000000000000000000000001000
	beq	pulsador2
	b	bucle
	
pulsador1:	
	mov	r3, r1		@ cargamos en r3 la espera del 1
	bl	espera			@ Salta a la rutina de espera
	str	r5, [r4, #GPSET0]	@ enciende speaker
	bl	espera			@ Salta a la rutina de espera
	str	r5, [r4, #GPCLR0]	@ apaga led
	b	bucle
	
pulsador2:
	b	bucle

espera:	push 	{r4, r5}		@ Save r5 and r6 in the stack
	ldr	r4, [r0, #STCLO]	@ Load CLO Timer
	add	r4, r3			@ Add waiting time -> this is our ending time
ret1:	ldr	r5, [r0, #STCLO]
	cmp	r5, r4
	blo	ret1			@ If lower, go back to read timer again
	pop	{r4, r5}		@ Restore r5 and r6
	bx	lr			@ Return from routine

