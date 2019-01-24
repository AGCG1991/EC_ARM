.include "inter.inc"

.text
	mov 	r0, #0b11010011
	msr	cpsr_c, r0
	mov 	sp, #0x8000000	@ Inicializ. pila en modo SVC
 
 
 /*El contador está dividido en dos partes, la parte baja CLO y la parte alta CHI. La parte alta no nos resulta */
	ldr     r4, =GPBASE
/* guia bits           xx999888777666555444333222111000*/
        ldr   	r5, =0b00000000001000000000000000001000
        str   	r5, [r4, #GPFSEL1]  @ Configura GPIO 17
/* guia bits           10987654321098765432109876543210*/
        ldr   	r5, =0b00000000000000100000000000000000
        ldr   	r0, =STBASE    	@ r0 es un parametro de espera (dir. base ST)

	ldr	r1, =1000000	@ r1 es un parametro de espera (microsec.)
bucle:	
        bl      espera        	@ Salta a rutina de espera
        str     r5, [r4, #GPSET0]	@ enciende led
        bl      espera        	@ Salta a rutina de espera
        str     r5, [r4, #GPCLR0]	@apaga led
        b       bucle

/* rutina que espera un segundo */
espera:	
	push	{r4,r5} @La pila la usamos para trabajara con los registros sin cambiar el valor de estos
        ldr     r4, [r0, #STCLO]	@ Lee contador en r4
        add   	r4, r1            	@ r4= r4+medio millon
ret1: 	ldr    	r5, [r0, #STCLO]
        cmp  	r5, r4            	@ Leemos CLO hasta alcanzar
        blo    	ret1              	@ el valor de r4
	pop	{r4,r5}
        bx     	lr