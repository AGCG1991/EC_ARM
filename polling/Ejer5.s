.include "inter.inc"

/* Los pulsadores estan en los GPIOS 2 y 3*/
.text
        ldr     r0, =GPBASE
/* guia bits           xx999888777666555444333222111000*/
        ldr   	r1, =0b00000000000000000001000000000000
        str	r1, [r0, #GPFSEL0]  @ Configura led amarillo GPIO 4
	
/* guia bits           10987654321098765432109876543210*/
        ldr   	r1, =0b00000000000000000000000000010000
	
bucle:
	ldr	r2, =9560
ret1:	subs	r2, #1
	bne	ret1
	@ cuando es igual a 0, continua
        str     r1, [r0, #GPCLR0]   @ Enciende led amarillo GPIO 4
	@ reinicio contador
	ldr	r2, =9560
ret2:	subs	r2, #1
	bne	ret2
	str	r1, [r0, #GPSET0] @ Apaga led
	b 	bucle
