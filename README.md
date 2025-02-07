# CandyNDS - Proyecto de Computadores (Fase 2)

## 📌 Descripción
Este proyecto implementa un clon de Candy Crush para la **Nintendo DS**, desarrollado como parte de la asignatura de **Computadores** en la **URV**. Se centra en la segunda fase del proyecto, que introduce **gráficos, animaciones y gestión de interrupciones** para mejorar la experiencia visual y de juego.

## 🎮 Características
✅ **Visualización de sprites y metabaldosas** usando gráficos 2D de la NDS.
✅ **Animación de gelatinas** mediante interrupciones del temporizador.
✅ **Gestión de movimientos y caídas** de los elementos.
✅ **Interfaz táctil** para interactuar con el juego.
✅ **Sistema de sugerencias** para el jugador.

## 🏗️ Arquitectura del Proyecto
El código está estructurado en **múltiples archivos**, cada uno con una responsabilidad específica:

### **1️⃣ candy2_main.c**
- Programa principal que controla el flujo del juego.
- Gestiona eventos, actualiza estados y maneja la lógica principal.

### **2️⃣ candy2_graf.c**
- Encargado de la **carga y manipulación gráfica**.
- Implementa la generación de mapas y sprites.

### **3️⃣ candy2_sopo.c**
- Funciones de soporte auxiliares.
- Incluye **animaciones y control de elementos**.

### **4️⃣ Interrupciones (RSI)**
- `RSI_timer0.s`: Movimiento de elementos.
- `RSI_timer1.s`: Escalado de sprites.
- `RSI_timer2.s`: Animación de gelatinas.
- `RSI_timer3.s`: Desplazamiento del fondo.

## 🖥️ Instalación y Ejecución
### **🔹 Requisitos**
- **DevkitARM** y **libnds** instalados.
- Emulador **DeSmuME** o una **Nintendo DS** con una Flashcart.

### **🔹 Compilación**
Ejecuta el siguiente comando en la terminal:
```sh
make
```

### **🔹 Cargar en Emulador**
Si usas **DeSmuME**, abre el archivo `.nds` generado con:
```sh
desmume candyNDS.nds
```

## 📜 Explicación de las Tareas Implementadas
### **🔹 Tarea 2C: Generación del Mapa de Baldosas**
- Se encarga de **dibujar** las baldosas del juego en la pantalla de la NDS.
- Utiliza **metabaldosas de 32x32 píxeles**.
- Usa la función `fija_metabaldosa()` para colocar correctamente cada bloque en la VRAM.

### **🔹 Tarea 2G: Animación de Gelatinas**
- Controla la **animación de gelatinas** mediante el **timer 2**.
- `rsi_timer2()` decrementa el índice de animación (`GEL_II`) y actualiza `GEL_IM`.
- La **interrupción VBlank** (`rsi_vblank()`) actualiza la pantalla con los cambios.

### **🔹 Tarea 2J: Gestión de Metabaldosas**
- `fija_metabaldosa()` coloca las metabaldosas en la VRAM.
- Utiliza bucles para recorrer las filas y columnas de cada metabaldosa.

## 📂 Estructura de Archivos
```
📁 candyNDS
├── 📂 source
│   ├── candy2_main.c
│   ├── candy2_graf.c
│   ├── candy2_sopo.c
│   ├── RSI_timer0.s
│   ├── RSI_timer1.s
│   ├── RSI_timer2.s
│   ├── RSI_timer3.s
│   ├── candy2_supo.s
│   ├── Makefile
│   ├── README.md  ⬅ (Este archivo)
│   ├── ...
└── 📂 graphics
    ├── Baldosas.s
    ├── Fondo.s
    ├── Sprites.s
```

## 📜 Licencia
Este proyecto se distribuye bajo la licencia **MIT**.

## 📧 Contacto
Para dudas o sugerencias, puedes contactarnos a través del **correo de los programadores** asignados a cada tarea.

