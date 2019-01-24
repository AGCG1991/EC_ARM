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
	
	ldr	r3, =0
	

/* Configuro GPIO 9 como salida */
        ldr     r0, =GPBASE
/* guia bits           xx999888777666555444333222111000*/
        ldr     r1, =0b00001000000000000000000000000000
        str     r1, [r0, #GPFSEL0]
/* guia bits           10987654321098765432109876543210*/
	ldr     r2, =0b00000000000000000000001000000000 @ cargo el selector del gpio 9

/* Programo contador C3 para futura interrupcion */
        ldr     r0, =STBASE
        ldr     r1, [r0, #STCLO]
	ldr	r2, =500000     @ 0.5 segundos
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
	push    {r0, r1, r2}          @ Salvo registros

        ldr     r0, =GPBASE

        eors	r3, #1
	ldr     r2, =0b00000000000000000000001000000000
        streq	r2, [r0, #GPSET0] @ Enciendo LED
	strne	r2, [r0, #GPCLR0] @ Apago LED

	@ Clear Event de las interrupciones
	/* Con esto libero los recursos y permito otra futura interrupcion*/
	ldr  	r0, =STBASE
	mov 	r1, #0b1000 @C3
	str   	r1,[r0, #STCS]
	
	@ Volvemos a programar la interrupciones
	ldr     r0, =STBASE
        ldr     r1, [r0, #STCLO]
	ldr	r2, =500000     @ 0.5 segundos
        add     r1, r2
        str     r1, [r0, #STC3]

        pop     {r0, r1, r2}          @ Recupero registros
        subs    pc, lr, #4        @ Salgo de la RTI
