.include "inter.inc"

/* Los pulsadores estan en los GPIOS 2 y 3*/
.text
	
	/* Agrego vector interrupcion */
        mov r0, #0
        ADDEXC  0x18, irq_handler

	/* Inicializo la pila en modos IRQ y SVC */
        mov     r0, #0b11010010   @ Modo IRQ, FIQ&IRQ desact
        msr     cpsr_c, r0
        mov     sp, #0x8000
        mov     r0, #0b11010011   @ Modo SVC, FIQ&IRQ desact
        msr     cpsr_c, r0
        mov     sp, #0x8000000
	
	@ Configuro gpios 22 y 27 como salida
        ldr     r0, =GPBASE
	/*  guia leds  xx999888777666555444333222111000*/
        ldr   	r1, =0b00000000001000000000000001000000
        str	r1, [r0, #GPFSEL2]  @ Configura Leds verdes (GPIO 22,27)
/* guia bits           10987654321098765432109876543210*/
        ldr   	r1, =0b00001000010000000000000000000000
        str     r1, [r0, #GPSET0]   @ Enciende leds verdes (GPIO 22,27)
	
	@ Habilito GPIO 2 Y 3 (BOTONES) para interrupciones
	/* guia bits   10987654321098765432109876543210*/
        ldr   	r1, =0b00000000000000000000000000001100
	str	r1, [r0, #GPFEN0] @ configuro las entradas
	
	@ Habilito las interrupciones, local y globalmente
	ldr	r0, =INTBASE
	/* guia bits   10987654321098765432109876543210*/
	ldr	r1, =0b00000000000100000000000000000000
	str	r1, [r0, #INTENIRQ2]
	ldr	r0, =0b01010011 @ Modo SVC, IRQ activo
	msr	cpsr_c, r0

bucle:	b bucle		@ bucle infinito

irq_handler:
	push {r0, r1} @ almaceno registros
	ldr	r0, =GPBASE
	
	@ Apago LEDs 22, 27
	/* guia bits   10987654321098765432109876543210*/
	ldr	r1, =0b00001000010000000000000000000000
	str	r1, [r0, #GPCLR0]
	
	@ consulto si se ha pulsado gpio 2
	ldr	r1, [r0, #GPEDS0]
	/* guia bits   10987654321098765432109876543210*/
	ands	r1, #0b00000000000000000000000000000100
	
	/* guia bits   10987654321098765432109876543210*/
	moveq	r1, #0b00001000000000000000000000000000 @ si es, 27
	movne	r1, #0b00000000010000000000000000000000 @ si no es, 22
	str	r1, [r0, #GPSET0]

	@ Clear Event de las interrupciones
	mov 	r1, #0b1100 @2,3
	str   	r1,[r0, #GPEDS0]
	
	pop {r0, r1} @ recupero registros
	
	subs    pc, lr, #4 @ Salgo de la RTI






