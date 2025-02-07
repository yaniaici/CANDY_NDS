#include <nds.h>
#include <stdio.h>
#include <time.h>
#include "candy1_incl.h"

/* Variables globales */
char matrix[ROWS][COLUMNS];		// matriz global de juego
int seed32;						// semilla de números aleatorios
int level = 0;					// nivel del juego (nivel inicial = 0)
int points;						// contador global de puntos
int movements;					// número de movimientos restantes
int gelees;						// número de gelatinas restantes

/* actualizar_contadores(code): actualiza los contadores que se indican con el
	parámetro 'code', que es una combinación binaria de booleanos, con el
	siguiente significado para cada bit:
		bit 0:	nivel
		bit 1:	puntos
		bit 2:	movimientos
		bit 3:	gelatinas  */
void actualizar_contadores(int code)
{
	if (code & 1) printf("\x1b[38m\x1b[1;8H %d", level);
	if (code & 2) printf("\x1b[39m\x1b[2;8H %d  ", points);
	if (code & 4) printf("\x1b[38m\x1b[1;28H %d ", movements);
	if (code & 8) printf("\x1b[37m\x1b[2;28H %d ", gelees);
}

#define NUMTESTS1E 14
#define NUMTESTS1F 5
#define NUMTESTS (NUMTESTS1E + NUMTESTS1F)
short nmap[] = {4, 4, 4, 4, 4, 4, 4, 5, 5, 5, 5, 6, 6, 8, 9, 4, 5, 6};
short posX[] = {0, 0, 0, 0, 4, 4, 4, 0, 0, 5, 4, 1, 1, 1};
short posY[] = {2, 2, 2, 2, 4, 4, 4, 0, 0, 0, 4, 3, 3, 5};
short cori[] = {0, 1, 2, 3, 0, 1, 2, 0, 3, 0, 0, 1, 3, 0};
short resp[] = {1, 2, 1, 1, 2, 1, 1, 3, 1, 3, 5, 2, 4, 2};

int main(void)
{
	int ntest = 13; // Inicializamos en 0 para comenzar desde el primer test
	int result1E;

	consoleDemoInit();			// Inicialización de pantalla de texto
	printf("candyNDS (prueba tarea 1E)\n");
	printf("\x1b[38m\x1b[1;0H  nivel:");
	level = nmap[ntest];
	actualizar_contadores(1);
	copia_matriz(matrix, mapas[level]); // Cargar el mapa inicial en la matriz
	escribe_matriz_testing(matrix); // Mostrar la matriz en pantalla
	swiWaitForVBlank(); // Esperar un VBlank

	do // Bucle principal de pruebas
	{
		if (ntest < NUMTESTS1E) {
			printf("\x1b[39m\x1b[2;0H test %d: posXY (%d, %d), c.ori %d", ntest, posX[ntest], posY[ntest], cori[ntest]);
			printf("\x1b[39m\x1b[3;0H resultado esperado: %d", resp[ntest]);
		
			result1E = cuenta_repeticiones(matrix, posY[ntest], posX[ntest], cori[ntest]);
		
			printf("\x1b[39m\x1b[4;0H resultado obtenido: %d", result1E);
			retardo(5);
			printf("\x1b[38m\x1b[5;19H (pulse A/B)");
		} else if (ntest < NUMTESTS) {
			printf("\x1b[39m\x1b[0;0HcandyNDS (prueba tarea 1F)\n");
			printf("\x1b[39m\x1b[2;0H test %d:", ntest - NUMTESTS1E);
			while(baja_elementos(matrix)) // Actualización en pantalla durante la caída
			{
				actualizar_contadores(4); // Actualizar movimientos restantes (si están cambiando)
				escribe_matriz_testing(matrix); // Redibujar matriz tras cada caída
				retardo(40);
			}
			swiWaitForVBlank();
			escribe_matriz_testing(matrix);
			retardo(5);
			printf("\x1b[38m\x1b[5;19H (pulse A/B)");
		}
		
		do
		{
			swiWaitForVBlank();
			scanKeys(); // Esperar pulsación tecla 'A' o 'B'
		} while (!(keysHeld() & (KEY_A | KEY_B)));
		
		printf("\x1b[2;0H                               ");
		printf("\x1b[3;0H                               ");
		printf("\x1b[4;0H                               ");
		printf("\x1b[38m\x1b[5;19H            ");
		retardo(5);
		
		if (keysHeld() & KEY_A) // Si pulsa 'A'
		{
			ntest++; // Siguiente test
			if (ntest < NUMTESTS && nmap[ntest] != level) // Cambiar el mapa si es diferente
			{
				level = nmap[ntest];
				actualizar_contadores(1);
				copia_matriz(matrix, mapas[level]);
				escribe_matriz_testing(matrix);
			}
		}

		if (keysHeld() & KEY_B)
		{
			copia_matriz(matrix, mapas[level]);
			escribe_matriz_testing(matrix);
		}
		
	} while (ntest < NUMTESTS); // Bucle de pruebas

	printf("\x1b[38m\x1b[5;19H (fin tests)");
	do { swiWaitForVBlank(); } while(1); // Bucle infinito
	return 0; // Nunca se alcanzará
}
