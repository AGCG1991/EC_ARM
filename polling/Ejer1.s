.include "inter.inc"


.text
        ldr     r0, =GPBASE
/* guia bits           xx999888777666555444333222111000*/
        ldr   	r1, =0b00000000001000000000000001000000
        str	r1, [r0, #GPFSEL2]  @ Configura GPIO 22,27
		
		@GPSEL2 Selecciona los gpio entorno al 20-29. Va de 10 en 10
		/*Existen 3 opciones 
			000 -> Entrada
			001 -> Salida
			010-111->Otros modos no utilizados
		*/
/* guia bits           10987654321098765432109876543210*/
        ldr   	r1, =0b00001000010000000000000000000000
        str     r1, [r0, #GPSET0]   @ Enciende GPIO 22,27
		@GPSET0 Selecciono que GPIO quiero encender en este caso el 22 y el 27
infi:  	b       infi
