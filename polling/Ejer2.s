.include "inter.inc"

/* Los pulsadores estan en los GPIOS 2 y 3*/
.text
        ldr     r0, =GPBASE 
		/* Declaro la constante y la guardo en r0. GPBASE está guardado en memoria (lo cargamos mediante la librería inter.inc */
		/*a la dirección base se la suma un offset para modificar la posición de memoria */
/* guia bits           xx999888777666555444333222111000*/
        ldr   	r1, =0b00000000001000000000000001000000
        str	r1, [r0, #GPFSEL2]  @ Configura Leds verdes (GPIO 22,27)
		@SELECCIONAMOS 22 Y 27
		@Queremos encender los GPIO 22 Y 27, para ello ponemos como salida 2 y 7 (previamente hemos configurado GPFSEL2)
		
/* guia bits           10987654321098765432109876543210*/
        ldr   	r1, =0b00001000010000000000000000000000
        str     r1, [r0, #GPSET0]   @ Enciende leds verdes (GPIO 22,27)
		
	/*COMENZAMOS EL SONDEO*/
bucle:	
	ldr	r1, [r0, #GPLEV0] 
	/*GPLEV0 estos puertos devuelven el valor del pin respectivo, en función de si están siendo
	pulsados o no*/
	
/* guia bits   10987654321098765432109876543210*/
	tst	r1, #0b00000000000000000000000000000100 @Comprueba el flag de signo. Comprobamos el GPIO 2
	beq	pulsador1 @Salta si el flag z=1 (si es pulsado el botón 1) , si Z=0, no saltará
			
/* guia bits   10987654321098765432109876543210*/	
	tst	r1, #0b00000000000000000000000000001000 @Comprueba el flag de signo. Comprobamos el GPIO 3
	beq	pulsador2 @Salta si el flag z=1 (si es pulsado el botón 1) , si Z=0, no saltará
	b 	bucle

	/*Microrutina para encender LEDS en función de los botones pulsados */
	@Inicialmente, están los 2 encendidos, pulsar uno, significa que el otro debe apagarse.
pulsador1:	
/* guia bits           10987654321098765432109876543210*/
        ldr   	r1, =0b00001000000000000000000000000000
        str     r1, [r0, #GPSET0]   @ Enciende 27
/* guia bits           10987654321098765432109876543210*/
        ldr   	r1, =0b00000000010000000000000000000000
        str     r1, [r0, #GPCLR0]   @ Apaga 22
		/* GPCLR0 borra o apaga lo contenido en GPIO 22, en este caso 
	b 	bucle
pulsador2:
/* guia bits           10987654321098765432109876543210*/
        ldr   	r1, =0b00001000000000000000000000000000
        str     r1, [r0, #GPCLR0]   @ Apaga 27
/* guia bits           10987654321098765432109876543210*/
        ldr   	r1, =0b00000000010000000000000000000000
        str     r1, [r0, #GPSET0]   @ Enciende 22
	b 	bucle

	/* Para ello tenemos los puertos GPSETn y GPCLRn, donde GPSETn pone un 1 y GPCLRn pone un 0 */
