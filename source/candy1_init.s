@;=                                                          	     	=
@;=== candy1_init.s: rutinas para inicializar la matriz de juego	  ===
@;=                                                           	    	=
@;=== Programador tarea 1A: sarah.guellil@estudiants.urv.cat				  ===
@;=== Programador tarea 1B: sarah.guellil@estudiants.urv.cat				  ===
@;=                                                       	        	=



.include "candy1_incl.i"



@;-- .bss. variables (globales) no inicializadas ---
.bss
		.align 2
@; matrices de recombinación: matrices de soporte para generar una nueva matriz
@;	de juego recombinando los elementos de la matriz original.
	mat_recomb1:	.space ROWS*COLUMNS
	mat_recomb2:	.space ROWS*COLUMNS



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1A;
@; inicializa_matriz(*matriz, num_mapa): rutina para inicializar la matriz de
@;	juego, primero cargando el mapa de configuración indicado por parámetro (a
@;	obtener de la variable global mapas[][][]) y después cargando las posiciones
@;	libres (valor 0) o las posiciones de gelatina (valores 8 o 16) con valores
@;	aleatorios entre 1 y 6 (+8 o +16, para gelatinas)
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocará la rutina
@;			mod_random()
@;		* para evitar generar secuencias se invocará la rutina
@;			cuenta_repeticiones() (ver fichero 'candy1_move.s')
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;		R1 = número de mapa de configuración
	.global inicializa_matriz
inicializa_matriz:
	push {r1-r10, r12, lr}
	ldr r3, =mapas
	mov r9, r0
	mov r4, #ROWS
	mov r5, #COLUMNS
	mul r7, r4, r5 				@; calculamos 9*9 =81
	mla r4, r7, r1, r3 			@; se calcula la direccion de mem donde se guarda mapa de configuración
	
	mov r1, #0 					@; filas a 0
.LROWS:
	mov r2, #0 					@; columnas a 0
.LCOLS:
	mla r10, r1, r5, r2 		@; dirección celda actual
	ldrb r6, [r4, r10]		 	@; cargar posicion actual en r6
	
	and r7, r6, #0x07 			@;bits 2..0 
	tst r6, #0x07 				@; si es igual a 0 es un espacio vacio es que necesita un random
	bne .LNoRand 				@; si no es se guarda el valor

.LRand:  
	mov r0, #6   				@; Rango maximo 0-5
	bl mod_random
	add r0, #1  				@; Sumamos 1 por si sale el num 0
	add r6, r0  				@; Añadimos las gelatinas 
	strb r6, [r9, r10]
	
	mov r3, #2   				@; checkeamos oeste
	.LCheckRepeticiones:
	mov r0, r9 
	bl cuenta_repeticiones
	cmp r0, #3
	blt .LCheckNorte  
	ldrb r6, [r4, r10]
	b .LRand         
	
	.LCheckNorte:
	add r3, #1  				@; checkeamos norte
	cmp r3, #4 
	blt .LCheckRepeticiones
	b .LFinRutina

.LNoRand:
	strb r6, [r9, r10]  		@; guardamos directamente si no necesita random 

.LFinRutina:
	add r2, #1
	cmp r2, #COLUMNS
	blt .LCOLS

	add r1, #1
	cmp r1, #ROWS
	blt .LROWS

		
	mov r0, r2
	pop {r1-r10, r12, pc}

@;TAREA 1B;
@; recombina_elementos(*matriz): rutina para generar una nueva matriz de juego
@;	mediante la reubicación de los elementos de la matriz original, para crear
@;	nuevas jugadas.
@;	Inicialmente se copiará la matriz original en mat_recomb1[][], para luego ir
@;	escogiendo elementos de forma aleatoria y colocándolos en mat_recomb2[][],
@;	conservando las marcas de gelatina.
@;	Restricciones:
@;		* para obtener elementos de forma aleatoria se invocará la rutina
@;			mod_random()
@;		* para evitar generar secuencias se invocará la rutina
@;			cuenta_repeticiones() (ver fichero 'candy1_move.s')
@;		* para determinar si existen combinaciones en la nueva matriz, se
@;			invocará la rutina hay_combinacion() (ver fichero 'candy1_comb.s')
@;		* se puede asumir que siempre existirá una recombinación sin secuencias
@;			y con posibles combinaciones
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
	.global recombina_elementos
recombina_elementos:
	push {r1-r12, lr}
	mov r4, #ROWS
	mov r5, #COLUMNS 
	ldr r6, =mat_recomb1
	ldr r7, =mat_recomb2
	mov r11, #0
	
.LInicioRecombina:
	mov r1, #0   				@;fila actual a 0
	mov r10, r0  				@;copiar matriz de juego en r10
	
.LROW1:
	mov r2, #0  				@; col actual a 0
	
.LCOL1:
	mla r8, r1, r5, r2  		@; calculamos posición actual en la matriz
	ldrb r9, [r10, r8]  		@; cargamos el valor en dicha posición
	
	and r12, r9, #0x07 			@;bits 2..0 
	tst r12, r12 				@; si es igual a 0, 8, 16
	beq .ConvertirACero
	cmp r12, #0x07
	bne .LVerificarGelatina
	
	.ConvertirACero:
	mov r9, #0

.LVerificarGelatina:
	cmp r9, #9  
	bge .LEliminarGelatina 		@; si es mayor o igual que 9 tiene gelatina (simple o doble)
	strb r9, [r6, r8] 			@; sino guardamos valor
	
	add r2, #1 					@; recorremos la matriz eliminando los 15, 7 y las gelatinas 
	cmp r2, r5
	blt .LCOL1
	add r1, #1
	cmp r1, r4
	beq .LFin1
	b .LROW1

.LEliminarGelatina:
	sub r9, #8 					@; Le quitamos una gelatina simple, si resulta que es doble volveremos aquí 
 	b .LVerificarGelatina

.LFin1: 
	mov r1, #0  				@; volvemos a inicializar las filas a 0
	
.LROW2:
	mov r2, #0  				@; cols a 0 
	
.LCOL2:
	mla r8, r1, r5, r2 			@; calculamos posición matriz  
	ldrb r9, [r10, r8] 			@; cargamos el valor
	

	and r12, r9, #0x07 			@;bits 2..0 
	tst r12, r12 				@; si es igual a 0, 8, 16
	bne .LNoVacio				@; si no esta vacío guardamos lo que tiene
	
	add r12, r9, #0x18  		@; bits 4..3 
	
	cmp r12, #0x0				@; si es 0 asignamos el num 30 
	moveq r9, #30
	beq .LGuardarElemento 
	cmp r12, #0x08				@; si es 8 asignamos el num 31 para no confundirlo con las gelatinas NO vacías
	moveq r9, #31
	beq .LGuardarElemento 
	cmp r12, #0x10				@; si es 16 asignamos el num 32 = =
	moveq r9, #32
	beq .LGuardarElemento
	
	.LNoVacio:
	and r12, r9, #0x07 			@; comprobamos bits 2..0
	cmp r12, #0x07				@; si son 111 (hueco o bloque) guardamos directamente
	beq .LGuardarElemento 
	
	and r12, r9, #0x18  		@; comprobamos bits 4..3
	cmp r12, #0x0				@; si son 0 es un valor simple
	moveq r9, #0   
	beq .LGuardarElemento 
	
	b .LConservarGelatina  		@; si no, llevan gelatina


.LGuardarElemento:
	strb r9, [r7, r8]  			@;guardamos en mat2 los bloques solidos y huecos
	
	add r2, #1
	cmp r2, r5
	blt .LCOL2
	add r1, #1
	cmp r1, r4
	bgt .LFin2
	b .LROW2

.LConservarGelatina:
	sub r9, #1					@; restamos 1 y comparamos con 8
	cmp r9, #8
	beq .LGuardarElemento  		@; si es 8 lleva gelatina simple, sino comparamos con 16
	cmp r9, #16 
	beq .LGuardarElemento 
	
	b .LConservarGelatina		@; si no es ni 8 ni 16, volvemos al incio del bucle

.LFin2:
	mov r1, #0
	
.LROW3: 
	mov r2, #0

.LCOL3:
	mla r8, r1, r5, r2
	ldrb r9, [r7, r8]			@; obtenemos el valor de mat_recomb2
	
	cmp r9, #30 
	bgt .LConvertirVacio  		@; si es mayor que 30 es un espacio vacio con o sin gelatina que lo devolvemos a su valor original 
	cmp r9, #15
	beq .LNoRestituir
	cmp r9, #7 
	beq .LNoRestituir 			@; los huecos y los bloques también se mantienen
	b .LPosicionRandom			@; si no es vacio ni hueco ni bloque le buscamos un random

.LGuardarElementoNuevo:
	add r0, r9					@; le sumamos la gelatina si tiene
	strb r0, [r7, r8]			@; guardamos
	
	mov r0, r7					
	mov r3, #2					@; checkeamos oeste
	bl cuenta_repeticiones
	cmp r0, #3
	bge .LRestituir
	mov r0, r7
	add r3, #1					@; checkeamos norte
	bl cuenta_repeticiones 
	cmp r0, #3
	blt .LSiguienteCasilla 		@; si no hay repeticiones vamos a la siguiente casilla
	
.LRestituir:
	strb r9, [r7, r8]			@; si hay repeticiones entonces devolvemos el valor que habia
	add r11, #1					@; aumentamos el contador
	b .LPosicionRandom			@; buscamos otro random que no forme secuencia
	
.LSiguienteCasilla:
	mov r3, #0  
	strb r3, [r6, r12]  		@; Vaciamos posicion para no volver a cogerlo 
	
.LNoRestituir:
	mov r11, #0					@; inicializamos el contador y pasamos a la siguiente casilla
	add r2, #1
	cmp r2, r5
	blt .LCOL3
	add r1, #1
	cmp r1, r4
	bge .LFin3
	b .LROW3
	
.LConvertirVacio:
	cmp r9, #30					@; convertimos los 30 en 0, los 31 en 8 y los 32 en 16 y guardamos
	moveq r9, #0
	cmp r9, #31
	moveq r9, #8
	cmp r9, #32
	moveq r9, #16
	strb r9, [r7, r8]
	b .LNoRestituir
	
.LPosicionRandom:	
	mov r0, #ROWS*COLUMNS 		@; num max del rango para el random
	cmp r11, #ROWS*COLUMNS		@; comparamos si hemos hecho el maximo de bucles
	beq .LInicioRecombina 		@; se atasca por lo tanto empezamos la rutina desde el incio

.LRepetirRandom:
	bl mod_random				@; obtenemos el random
	ldrb r0, [r6, r0]			@; recogemos el valor de la posicion random 
	cmp r0, #0					@; si esta vacio entonces llamamos otra vez al random
	beq .LPosicionRandom
	b .LGuardarElementoNuevo	@; sino guardamos el elemento

.LFin3:
	mov r3, #0					@; inicializamos posicion

.LContinuar:
	ldrb r2, [r7, r3]			@; cargamos el valor
	strb r2, [r10, r3]			@; lo guardamos en el registro 10
	add r3, #1					@; pasamos a la siguiente posicion
	cmp r3, #ROWS*COLUMNS
	beq .LFinRecombina
	b .LContinuar				@; asi con todas las posiciones

.LFinRecombina:
	mov r0, r10					@; matriz recombinada 
	pop {r1-r12, pc}


@;:::RUTINAS DE SOPORTE:::



@; mod_random(n): rutina para obtener un número aleatorio entre 0 y n-1,
@;	utilizando la rutina random()
@;	Restricciones:
@;		* el parámetro n tiene que ser un natural entre 2 y 255, de otro modo,
@;		  la rutina lo ajustará automáticamente a estos valores mínimo y máximo
@;	Parámetros:
@;		R0 = el rango del número aleatorio (n)
@;	Resultado:
@;		R0 = el número aleatorio dentro del rango especificado (0..n-1)
	.global mod_random
mod_random:
		push {r1-r4, lr}
	
		cmp r0, #2				@;compara el rango de entrada con el mínimo
		bge .Lmodran_cont
		mov r0, #2				@;si menor, fija el rango mínimo
	.Lmodran_cont:
		and r0, #0xff			@;filtra los 8 bits de menos peso
		sub r2, r0, #1			@;R2 = R0-1 (número más alto permitido)
		mov r3, #1				@;R3 = máscara de bits
	.Lmodran_forbits:
		cmp r3, r2				@;genera una máscara superior al rango requerido
		bhs .Lmodran_loop
		mov r3, r3, lsl #1
		orr r3, #1				@;inyecta otro bit
		b .Lmodran_forbits
		
	.Lmodran_loop:
		bl random				@;R0 = número aleatorio de 32 bits
		and r4, r0, r3			@;filtra los bits de menos peso según máscara
		cmp r4, r2				@;si resultado superior al permitido,
		bhi .Lmodran_loop		@; repite el proceso
		mov r0, r4			@; R0 devuelve número aleatorio restringido a rango

		pop {r1-r4, pc}



@; random(): rutina para obtener un número aleatorio de 32 bits, a partir de
@;	otro valor aleatorio almacenado en la variable global seed32 (declarada
@;	externamente)
@;	Restricciones:
@;		* el valor anterior de seed32 no puede ser 0
@;	Resultado:
@;		R0 = el nuevo valor aleatorio (también se almacena en seed32)
random:
	push {r1-r5, lr}
		
	ldr r0, =seed32				@;R0 = dirección de la variable seed32
	ldr r1, [r0]				@;R1 = valor actual de seed32
	ldr r2, =0x0019660D
	ldr r3, =0x3C6EF35F
	umull r4, r5, r1, r2
	add r4, r3					@;R5:R4 = nuevo valor aleatorio (64 bits)
	str r4, [r0]				@;guarda los 32 bits bajos en seed32
	mov r0, r5					@;devuelve los 32 bits altos como resultado
		
	pop {r1-r5, pc}	



.end
