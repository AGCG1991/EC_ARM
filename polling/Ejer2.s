.include "inter.inc"

/* Los pulsadores estan en los GPIOS 2 y 3*/
.text
        ldr     r0, =GPBASE
/* guia bits           xx999888777666555444333222111000*/
        ldr   	r1, =0b00000000001000000000000001000000
        str	r1, [r0, #GPFSEL2]  @ Configura Leds verdes (GPIO 22,27)
/* guia bits           10987654321098765432109876543210*/
        ldr   	r1, =0b00001000010000000000000000000000
        str     r1, [r0, #GPSET0]   @ Enciende leds verdes (GPIO 22,27)
	
bucle:	
	ldr	r1, [r0, #GPLEV0]
/* guia bits   10987654321098765432109876543210*/
	tst	r1, #0b00000000000000000000000000000100
	beq	pulsador1
/* guia bits   10987654321098765432109876543210*/	
	tst	r1, #0b00000000000000000000000000001000
	beq	pulsador2
	b 	bucle

pulsador1:	
/* guia bits           10987654321098765432109876543210*/
        ldr   	r1, =0b00001000000000000000000000000000
        str     r1, [r0, #GPSET0]   @ Enciende 27
/* guia bits           10987654321098765432109876543210*/
        ldr   	r1, =0b00000000010000000000000000000000
        str     r1, [r0, #GPCLR0]   @ Apaga 22
	b 	bucle
pulsador2:
/* guia bits           10987654321098765432109876543210*/
        ldr   	r1, =0b00001000000000000000000000000000
        str     r1, [r0, #GPCLR0]   @ Apaga 27
/* guia bits           10987654321098765432109876543210*/
        ldr   	r1, =0b00000000010000000000000000000000
        str     r1, [r0, #GPSET0]   @ Enciende 22
	b 	bucle

