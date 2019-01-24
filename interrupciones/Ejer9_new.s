        .include  "inter.inc"
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
	

/* Configuro GPIO 9 como salida */
        ldr     r0, =GPBASE
/* guia bits           xx999888777666555444333222111000*/
        ldr     r1, =0b00001000000000000000000000000000
        str     r1, [r0, #GPFSEL0]
/* guia bits           xx999888777666555444333222111000*/
        ldr     r1, =0b00000000001000000000000000001001
        str     r1, [r0, #GPFSEL1]
/* guia bits           xx999888777666555444333222111000*/
        ldr     r1, =0b00000000001000000000000001000000
        str     r1, [r0, #GPFSEL2]
		/* Como queremos hacer una "escalera" donde se vayan sucediendo el encendido de los leds , seleccionamos todos ellos 
		en primer lugar con GPFSEL0, seleccionamos el GPIO 9
		en segundo lugar con GPFSEL1, seleccionamos los GPIO´S 10, 11, 17
		en tercer lugar con GPFSEL2, seleccionamos los GPIO´S 22,27 */
	
	
/* guia bits       10987654321098765432109876543210*/
	ldr     r2, =0b00000000000000000000001000000000 @ cargo el selector del gpio 9

/* Programo contador C3 para futura interrupcion */
        ldr     r0, =STBASE
        ldr     r1, [r0, #STCLO]
	ldr	r2, =400000     @ 0.5 segundos
        add     r1, r2
        str     r1, [r0, #STC3]

/* Habilito interrupciones, local y globalmente */
        ldr     r0, =INTBASE
        mov     r1, #0b1000
        str     r1, [r0, #INTENIRQ1]
        mov     r0, #0b01010011   @ Modo SVC, IRQ activo
        msr     cpsr_c, r0

/* Repetir para siempre */
bucle:  b       bucle

/* Rutina de tratamiento de interrupción */
irq_handler:
	push    {r0, r1, r2, r3}          @ Salvo registros

        ldr     r0, =GPBASE
       
	@ Apago todos los leds
/* guia bits           10987654321098765432109876543210*/
	ldr     r2, =0b00001000010000100000111000000000
	str	r2, [r0, #GPCLR0] @ Apago LED
	
	ldr	r3, =cuenta
	ldr	r2, [r3]            @ Leo  variable  cuenta
	subs	r2, #1               @ Decremento
	moveq	r2, #6               @ Si es 0,  volver a 6
	str	r2, [r3]      @ Escribo  cuenta
	ldr	r2, [r3, +r2, LSL #2] @ Leo  secuencia
	str	r2, [r0, #GPSET0] @ Escribo  secuencia  en LEDs

	@ Clear Event de las interrupciones
	ldr  	r0, =STBASE
	mov 	r1, #0b1000 @C3
	str   	r1,[r0, #STCS]
	
	@ Volvemos a programar la interrupciones
	ldr     r0, =STBASE
        ldr     r1, [r0, #STCLO]
	ldr	r2, =400000     @ 0.5 segundos
        add     r1, r2
        str     r1, [r0, #STC3]

        pop     {r0, r1, r2, r3}          @ Recupero registros
        subs    pc, lr, #4        @ Salgo de la RTI

cuenta:	.word 1
/*              10987654321098765432109876543210*/
seq:	.word 0b00000000000000000000001000000000
	.word 0b00000000000000000000010000000000
	.word 0b00000000000000000000100000000000
	.word 0b00000000000000100000000000000000
	.word 0b00000000010000000000000000000000
	.word 0b00001000000000000000000000000000
	