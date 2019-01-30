.include "inter.inc"
.include "notas.inc"
.text

ADDEXC 0x18, irq_handler
ADDEXC 0x1c, fiq_handler

/* Inicializo la pila en modos FIQ, IRQ y SVC */
mov r0, # 0b11010001 @ Modo FIQ, FIQ & IRQ desact
msr cpsr_c, r0
mov sp, # 0x4000
mov r0, # 0b11010010 @ Modo IRQ, FIQ & IRQ desact
msr cpsr_c, r0
mov sp, # 0x8000
mov r0, # 0b11010011 @ Modo SVC, FIQ & IRQ desact
msr cpsr_c, r0
mov sp, # 0x8000000

/* Configuro GPIOs 4, 9, 10, 11, 17, 22 y 27 como salida */
ldr r0, = GPBASE
ldr r1, = 0b00001000000000000001000000000000
str r1, [ r0, # GPFSEL0 ]
/* guia bits xx999888777666555444333222111000 */
ldr r1, = 0b00000000001000000000000000001001
str r1, [ r0, # GPFSEL1 ]
ldr r1, = 0b00000000001000000000000001000000
str r1, [ r0, # GPFSEL2 ]

/* Programo C1 y C3 para dentro de 2 microsegundos */
ldr r0, = STBASE
ldr r1, [ r0, # STCLO ]
add r1, # 2
str r1, [ r0, # STC1 ]
add r1, #2
str r1, [ r0, # STC3 ]

/* Habilito C1 para IRQ */
ldr r0, = INTBASE
mov r1, # 0b0010
str r1, [ r0, # INTENIRQ1 ]
mov r1, #0b00000000001000000000000000000000

/* Habilito C3 para FIQ */
mov r1, # 0b10000011
str r1, [ r0, # INTFIQCON ]

/* Habilito interrupciones globalmente */
mov r0, # 0b00010011 @ Modo SVC, FIQ & IRQ activo
msr cpsr_c, r0

ldr r1, =patron
mov r2, #1
mov r4, #2
ldr r0, =GPBASE

bucle :
	
	ldr r3,[r0,#GPLEV0] @Boton GPIO2 izquierdo
	ands r3,#0b00000000000000000000000000000100
	streq r2, [r1]

	ldr r3,[r0,#GPLEV0] @Boton derecho GPIO3
	ands r3,#0b00000000000000000000000000001000
	streq r4, [r1]   
	
	b bucle
	
irq_handler :
push { r0, r1, r2, r3, r4, r5, r6, r7 }

ldr r0, = GPBASE
ldr r6, =STBASE
ldr r2, =patron

ldr r1, [r2]
cmp r1, #2 @Si r1 es cero salta
beq ledsBotonDerecho

ledsBotonIzquierdo:
	/* Apago todos LEDs */
	ldr r1, = cuenta
	ldr r2, = 0b00001000010000100000111000000000
	str r2, [ r0, # GPCLR0 ]
	ldr r2, [ r1 ] @ Leo variable cuenta
	subs r2, # 1 @ Decremento
	moveq r2, # 3 @ Si es 0, volver a 3
	str r2, [ r1 ] @ Escribo cuenta
	ldr r2, [ r1, r2, LSL #2 ] @ Leo secuencia
	str r2, [ r0, # GPSET0 ] @ Escribo secuencia en LEDs
	b altavoz
	
ledsBotonDerecho:
	ldr r1, =ledst
	ldr r2, [r1] @ Leo variable 
	ands r2, #1 @ Invierto bit 0 
	str r2, [r1] @ Escribo variable
        ldr r1, =0b00001000010000100000111000000000
        streq	r1, [r0, #GPSET0] @ Enciendo LED
	strne	r1, [r0, #GPCLR0] @ Apago LED
	
	

	
	b altavoz

/*Duracion del altavoz*/
altavoz:
	ldr r3, =indice @Leo variable notas
	ldr r5, =duratFS @Cargo duracion notas
	ldr r7, [r3]
	add r7, #1 @ incremento el contador
	cmp r7, #NUMNOTAS @Compruebo si es 70 vuelve a 0
	moveq r7, #0
	ldr r4, [r5, r7, LSL #2]@leo secuencia notas
	str r7, [r3] @Guardo valor de la pila

/* Reseteo estado interrupción de C1 */
mov r2, # 0b0010
str r2, [ r6, # STCS ]


/* Programo siguiente interrupción dependiendo de la duracion de la nota */
ldr r2, [ r6, # STCLO ]
add r2, r4
str r2, [ r6, # STC1 ]

/*  Desactivo  los  dos  flags  GPIO  pendientes  de  atención*/
mov r1, #0b00000000000000000000000000001100
str      r1, [r0, #GPEDS0]

/* Recupero registros y salgo */
pop { r0, r1, r2, r3, r4, r5, r6, r7 }
subs pc, lr, #4

/* Rutina de tratamiento de interrupción FIQ */
fiq_handler :

ldr r8, = GPBASE
ldr r9, = bitson
ldr r11, =indice

/* Hago sonar altavoz invirtiendo estado de bitson */
ldr r10, [ r9 ]
eors r10, #1
str r10, [ r9 ]

/* Leo notas y luego el elemento correspondiente en notaFS */
ldr r9, [r11]
ldr r10, =notaFS @Cargo nota correspondiente
ldr r12, [ r10, r9, LSL # 2]


/* Pongo estado altavoz según variable bitson */
mov r10, # 0b10000 @ GPIO 4 ( altavoz )
streq r10, [ r8, # GPSET0 ]
strne r10, [ r8, # GPCLR0 ]

/* Reseteo estado interrupción de C3 */
saltoSilencio:
ldr r8, = STBASE
mov r10, # 0b1000
str r10, [ r8, # STCS ]

/* Programo retardo según valor leído en array */
ldr r10, [ r8, # STCLO ]
add r10, r12
str r10, [ r8, # STC3 ]

/* Salgo de la RTI */
subs pc, lr, #4


bitson:	.word 0 @ Bit 0 = Estado del altavoz
ledst: 	

patron: .word 0
cuenta : .word 1 @ Entre 1 y 6, LED a encender
secuen :
.word 0b0000000000000000001000000000 @1
.word 0b0000000000000000010000000000 @ 2
.word 0b0000000000000000100000000000 @ 3
.word 0b0000000000100000000000000000 @ 4
.word 0b0000010000000000000000000000 @5
.word 0b1000000000000000000000000000 @6 


		
	
	



	
indice: .word 0
.include "vader.inc"
