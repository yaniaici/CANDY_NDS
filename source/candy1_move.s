@;=                                                         	      	=
@;=== candy1_move: rutinas para contar repeticiones y bajar elementos ===
@;=                                                          			=
@;=== Programador tarea 1E: yani.aici@estudiants.urv.cat				  ===
@;=== Programador tarea 1F: yani.aici@estudiants.urv.cat			  ===
@;=                                                         	      	=



.include "candy1_incl.i"



@;-- .text. código de las rutinas ---
.text	
		.align 2
		.arm



@;TAREA 1E;
@; cuenta_repeticiones(*matriz,f,c,ori): rutina para contar el número de
@; repeticiones del elemento situado en la posición (f,c) de la matriz, 
@; visitando las siguientes posiciones según indique el parámetro de
@; orientación 'ori'.
@; Restricciones:
@; * sólo se tendrán en cuenta los 3 bits de menor peso de los códigos
@; almacenados en las posiciones de la matriz, de modo que se ignorarán
@; las marcas de gelatina (+8, +16)
@; * la primera posición también se tiene en cuenta, de modo que el número
@; mínimo de repeticiones será 1, es decir, el propio elemento de la
@; posición inicial
@; Parámetros:
@; R0 = dirección base de la matriz
@; R1 = fila 'f'
@; R2 = columna 'c'
@; R3 = orientación 'ori' (0 -> Este, 1 -> Sur, 2 -> Oeste, 3 -> Norte)
@; Resultado:
@; R0 = número de repeticiones detectadas (mínimo 1)
.global cuenta_repeticiones
cuenta_repeticiones:
    push {r1-r12, lr}    @; Preservamos los registros usados
    
    mov r12, r0            @; r12 apunta a la matriz
    mov r10, #COLUMNS      @; r10 = número de columnas (COLUMNS)
    mov r11, #ROWS         @; r11 = número de filas (ROWS)
    mla r8, r1, r10, r2    @; r8 = desplazamiento en la matriz
    add r6, r0, r8         @; r6 apunta al elemento (f,c) en la matriz
    ldrb r7, [r6]          @; r7 = valor de la posición (f,c)
    and r7, #7             @; r7 = valor con solo los 3 bits de menor peso
    mov r0, #1             @; r0 = contador de repeticiones (empieza en 1)
    cmp r7, #7             @; Comprobamos si es un bloque sólido (7)
    beq .Lconrep_fin
    cmp r7, #0             @; Comprobamos si es un espacio vacío (0)
    beq .Lconrep_fin
    cmp r3, #0
    beq .Lconrep_este
    cmp r3, #1
    beq .Lconrep_sur
    cmp r3, #2
    beq .Lconrep_oeste
    cmp r3, #3
    beq .Lconrep_norte
    b .Lconrep_fin
    
.Lconrep_este:
    add r2, #1             @; Incrementamos columna
    cmp r2, r10            @; Comprobamos si nos pasamos de columnas
    bge .Lconrep_fin
    mla r8, r1, r10, r2    @; Calculamos nueva posición
    add r6, r12, r8        @; r6 apunta al nuevo elemento en la matriz
    ldrb r9, [r6]          @; Cargamos el valor del nuevo elemento en r9
    and r9, #7             @; r9 = valor con solo los 3 bits de menor peso
    cmp r7, r9             @; Comparamos con el valor original
    bne .Lconrep_fin
    addeq r0, #1           @; Si son iguales, incrementamos el contador
    b .Lconrep_este

.Lconrep_sur:
    add r1, #1             @; Incrementamos fila
    cmp r1, r11            @; Comprobamos si nos pasamos de filas
    bge .Lconrep_fin
    mla r8, r1, r10, r2    @; Calculamos nueva posición
    add r6, r12, r8        @; r6 apunta al nuevo elemento en la matriz
    ldrb r9, [r6]          @; Cargamos el valor del nuevo elemento en r9
    and r9, #7             @; r9 = valor con solo los 3 bits de menor peso
    cmp r7, r9             @; Comparamos con el valor original
    bne .Lconrep_fin
    addeq r0, #1           @; Si son iguales, incrementamos el contador
    b .Lconrep_sur

.Lconrep_oeste:            
    sub r2, #1             @; Retrocedemos columna
    cmp r2, #0             @; Comprobamos si nos pasamos de la primera columna
    blt .Lconrep_fin
    mla r8, r1, r10, r2    @; Calculamos nueva posición
    add r6, r12, r8        @; r6 apunta al nuevo elemento en la matriz
    ldrb r9, [r6]          @; Cargamos el valor del nuevo elemento en r9
    and r9, #7             @; r9 = valor con solo los 3 bits de menor peso
    cmp r7, r9             @; Comparamos con el valor original
    bne .Lconrep_fin
    addeq r0, #1           @; Si son iguales, incrementamos el contador
    b .Lconrep_oeste

.Lconrep_norte:            
    sub r1, #1             @; Retrocedemos fila
    cmp r1, #0             @; Comprobamos si nos pasamos de la primera fila
    blt .Lconrep_fin
    mla r8, r1, r10, r2    @; Calculamos nueva posición
    add r6, r12, r8        @; r6 apunta al nuevo elemento en la matriz
    ldrb r9, [r6]          @; Cargamos el valor del nuevo elemento en r9
    and r9, #7             @; r9 = valor con solo los 3 bits de menor peso
    cmp r7, r9             @; Comparamos con el valor original
    bne .Lconrep_fin
    addeq r0, #1           @; Si son iguales, incrementamos el contador
    b .Lconrep_norte
    
.Lconrep_fin:
    pop {r1-r12, pc} @; Restauramos los registros y retornamos




@;TAREA 1F;
@; baja_elementos(*matriz): rutina para bajar elementos hacia las posiciones
@;	vacías, primero en vertical y después en diagonal; cada llamada a la función
@;	baja múltiples elementos una posición y devuelve cierto (1) si se ha
@;	realizado algún movimiento, o falso (0) si no se ha movido ningún elemento.
@;	Restricciones:
@;		* para las casillas vacías de la primera fila se generarán nuevos
@;			elementos, invocando la rutina mod_random() (ver fichero
@;			'candy1_init.s')
@;	Parámetros:
@;		R0 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica se ha realizado algún movimiento, de modo que pueden
@;				quedar movimientos pendientes; 0 si no ha movido nada 
	.global baja_elementos
baja_elementos:
		push {r4,lr}
		.Lbajar_elementos:
			mov r4, r0
			bl baja_verticales
			cmp r0, #0
			bleq baja_laterales @; Si no hay movimientos verticales, se hace en lateral
		
		
		pop {r4,pc}



@;:::RUTINAS DE SOPORTE:::

@; baja_verticales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en vertical; cada llamada a la función baja múltiples elementos una posición
@;	y devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento; 0 si no ha movido nada  
baja_verticales:
    push {r1-r9,lr}              @; Guarda los registros que se usarán
        mov r0, #0                @; Inicializa el contador de movimientos a 0
        mov r1, #ROWS             @; r1 almacena el número total de filas
        mov r2, #COLUMNS          @; r2 almacena el número total de columnas
        sub r7, r2, #1            @; r7 = última columna (COLUMNS - 1)
        add r7, r4                 @; r7 ahora es la dirección de la última celda de la primera fila
        mla r3, r1, r2, r4        @; r3 es la dirección de la última celda de la matriz
        sub r3, #1                @; Ajustamos r3 para apuntar a la última celda (de la matriz)
.Linicio_bucle_V:
        ldrb r5, [r3]             @; Cargamos el valor de la celda actual
        tst r5, #7                 @; Verificamos si el valor es 0, 8 o 16 sin modificarlos
        beq .Lbajar_vertical_V       @; Si es un número vacío, se procede a bajar elementos
.Lavanzar_V:
        sub r3, #1                @; Avanzamos a la celda anterior (izquierda)
        cmp r3, r7                @; Verificamos si hemos alcanzado la primera fila
        bgt .Linicio_bucle_V        @; Si no hemos llegado a la primera fila, continuamos
        cmp r3, r4                @; Comprobamos si nos salimos de la primera celda
        blt .Lfinal_bajar_verticales @; Si lo hacemos, hemos terminado
        ldrb r5, [r3]             @; Cargamos el valor de la celda
        tst r5, #7                 @; Verificamos si es un 0, 8 o 16
        bne .Lavanzar_V             @; Si no es, continuamos moviéndonos
        mov r0, #6                @; Preparamos para generar un número aleatorio (0-5)
        bl mod_random              @; Llamamos a la función mod_random para obtener un número aleatorio
        add r0, #1                 @; Ajustamos el número aleatorio para que esté en el rango (1-6)
        add r5, r0                 @; Aplicamos el tipo de gelatina al valor
        strb r5, [r3]              @; Guardamos la gelatina en la posición actual
        mov r0, #1                 @; Indicamos que se realizó un movimiento
        b .Lavanzar_V                @; Volvemos a avanzar
.Lbajar_vertical_V:
        sub r6, r3, r2            @; Subimos una celda
.Lcomprobar_vertical_V:    
        ldrb r9, [r6]             @; Cargamos el valor de la celda de arriba
        cmp r9, #7                @; Verificamos si es un bloque sólido
        beq .Lavanzar_V             @; Si es sólido, continuamos avanzando
        cmp r9, #15               @; Verificamos si es un espacio vacío
        beq .Lvacio_vertical_V       @; Si lo es, procedemos a manejar el hueco
        tst r9, #7                 @; Comprobamos si es un espacio vacío
        beq .Lavanzar_V             @; Si lo es, seguimos avanzando
        mov r8, r9                 @; Guardamos el valor de la celda de arriba
        and r9, #7                 @; Eliminamos el tipo de gelatina
        sub r8, r9                 @; Restamos el color al tipo de gelatina
        add r9, r5                 @; Sumamos el color al tipo de gelatina
        strb r9, [r3]              @; Guardamos el valor de la celda de arriba en la de abajo
        strb r8, [r6]              @; Guardamos un hueco (0/8/16) en la celda de arriba
        mov r0, #1                 @; Indicamos que se realizó un movimiento
        b .Lavanzar_V                @; Volvemos a avanzar
.Lvacio_vertical_V:
        sub r6, r2                @; Subimos una celda por encima del hueco
        cmp r6, r4                @; Verificamos si nos hemos salido del tablero
        bge .Lcomprobar_vertical_V   @; Si no, seguimos comprobando
        mov r0, #6                @; Generamos un número aleatorio (0-5) para un nuevo elemento
        bl mod_random              @; Llamamos a mod_random para obtener un nuevo número aleatorio
        add r0, #1                 @; Ajustamos el número aleatorio para que esté en el rango (1-6)
        add r5, r0                 @; Aplicamos el tipo de gelatina
        strb r5, [r3]              @; Guardamos la gelatina en la posición
        mov r0, #1                 @; Indicamos que se realizó un movimiento
        b .Lavanzar_V                @; Volvemos a avanzar
.Lfinal_bajar_verticales:
    pop {r1-r9,pc}               @; Restauramos registros y retornamos

@; baja_laterales(mat): rutina para bajar elementos hacia las posiciones vacías
@;	en diagonal; cada llamada a la función baja múltiples elementos una posición
@;	y devuelve cierto (1) si se ha realizado algún movimiento.
@;	Parámetros:
@;		R4 = dirección base de la matriz de juego
@;	Resultado:
@;		R0 = 1 indica que se ha realizado algún movimiento; 0 si no ha movido nada. 
baja_laterales:
    push {r1-r6,r12, lr}      @; Guardamos registros utilizados
        mov r12, #0            @; Inicializamos r12 para verificar movimientos
        mov r1, #ROWS-1       @; Fila actual comenzando desde la última
        mov r2, #COLUMNS-1    @; Columna actual comenzando desde la última
        mov r6, #COLUMNS       @; r6 almacena el número de columnas
        b .Lfor_columnas_L       @; Comienza el bucle para las columnas
.Lfor_filas_L:
        sub r1, #1            @; Decrementamos la fila
        mov r2, #COLUMNS-1    @; Reseteamos la columna a la última
        cmp r1, #0             @; Verificamos si hemos llegado a la primera fila
        beq .Lfinal_bajar_laterales @; Si es así, terminamos
.Lfor_columnas_L:
        mla r3, r6, r1, r2    @; Calculamos la dirección de la celda actual
        ldrb r5, [r4, r3]     @; Cargamos el valor de la celda
        tst r5, #7             @; Verificamos si es 0, 8 o 16
        bleq bajar_lateral_L     @; Si es así, procedemos a bajar
        cmp r0, #1
        moveq r12, #1          @; Marcamos que se realizó un movimiento
        sub r2, #1            @; Decrementamos la columna
        cmp r2, #0             @; Verificamos que no nos salgamos de la matriz
        blt .Lfor_filas_L      @; Si estamos fuera, continuamos a la siguiente fila
        b .Lfor_columnas_L       @; Continuamos con la siguiente columna
.Lfinal_bajar_laterales:
        mov r0,r12             @; Almacenamos el resultado de los movimientos en r0
    pop {r1-r6,r12, pc}         @; Restauramos los registros y retornamos

    @; baja_lateral: rutina para bajar elementos hacia las posiciones vacías
@; en diagonal; cada llamada a la función sólo baja elementos una posición y
@; devuelve cierto (1) si se ha realizado algún movimiento.
@; Parámetros:
@;     R1 = índice fila actual
@;     R2 = índice columna actual
@;     R3 = puntero a la posición vacía
@;     R4 = dirección base de la matriz de juego
@;     R5 = tipo de gelatina de la posición vacía
@;     R6 = #COLUMNS
@; Resultado:
@;     R0 = 1 indica que se ha realizado algún movimiento.

bajar_lateral_L:
    push {r1,r2,r7-r11,lr}       @; Guardamos registros utilizados
    mov r11, #0                   @; Inicializamos el comprobante de cambios
    mov r7, r2                    @; Guardamos la columna central en r7
    sub r1, #1                     @; Fila superior
    mov r0, #2                    @; Generamos un número aleatorio entre 0 y 1
    bl mod_random                 @; Llamamos a mod_random
    cmp r0, #0                    @; 0=izquierda, 1=derecha
    subeq r2, #1                  @; Casilla izquierda
    addne r2, #1                  @; Casilla derecha
    mov r0, #0                    @; Reiniciamos el valor de r0

    cmp r2, #0                    @; Comprobamos si nos salimos del borde izquierdo
    blt .Lcambiar_L                 @; Si es así, cambiamos de lado
    cmp r2, #COLUMNS              @; Comprobamos si nos salimos del borde derecho
    bge .Lcambiar_L                 @; Si es así, cambiamos de lado

.Lcomprobar_lateral:
    mla r8, r6, r1, r2            @; Calculamos la dirección de la celda actual
    ldrb r9, [r4, r8]             @; Cargamos el valor de la celda
    cmp r9, #7                    @; Si es un bloque sólido, cambiamos de lado
    beq .Lcambiar_L
    cmp r9, #15                   @; Si es un espacio vacío, cambiamos de lado
    beq .Lcambiar_L
    tst r9, #7                    @; Verificamos si es un hueco vacío
    beq .Lcambiar_L

    mov r10, r9                   @; Guardamos el valor de r9
    and r9, #7                    @; Eliminamos el tipo de gelatina
    sub r10, r9                    @; Restamos el color al tipo de gelatina para dejar un hueco del mismo tipo
    add r5, r9                    @; Sumamos el color al tipo de gelatina
    strb r10, [r4, r8]            @; Colocamos un hueco (0/8/16) en la celda de arriba
    strb r5, [r4, r3]             @; Colocamos la gelatina en la posición
    mov r0, #1                    @; r0=1 porque hemos realizado un cambio
    b .Lfinal_bajar_lateral       @; Saltamos a la finalización

.Lcambiar_L:
    add r11, #1                   @; Incrementamos el comprobante de cambios
    cmp r11, #2                   @; Si hemos intentado cambiar 2 veces, no hay movimiento posible
    beq .Lfinal_bajar_lateral     @; Si es así, terminamos
    cmp r2, r7                    @; Comparamos la columna actual con la central
    bgt .Lizquierda_L                @; Si es mayor, cambiamos a la izquierda; de lo contrario, a la derecha
.Lderecha_L:
    add r2, #1                    @; Nos movemos a la derecha
    b .Lcomprobar_lateral         @; Volvemos a comprobar
.Lizquierda_L:
    sub r2, #1                    @; Nos movemos a la izquierda
    b .Lcomprobar_lateral         @; Volvemos a comprobar

.Lfinal_bajar_lateral:
    pop {r1,r2,r7-r11, pc}        @; Restauramos registros y retornamos


.end
