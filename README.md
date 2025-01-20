# Compilador
A simple compiler for generate Three Address Code

## Pre-requisites
- Flex
- Bison
- GCC

## Files
- lexic.l: Flex file that defines the regular expressions for the lexer.
- syntactic.y: Bison grammar file that defines the grammar rules for the calculator.
- compiler.c & compiler.h: Main structure and functions of the compiler.
- symtab/datatypes.h: Definition of types for symtab and grammar logic.
### Utils
- quad.c: functions to manage the generation of the Three Adress Code
- functions.c & functions.h: Auxiliar functions for running the compiler.

## Working with the compiler
### Build

`$ make`

### Run

`$ ./compiler INPUT_FILE OUTPUT_FILE`

### Clean

`$ make clean`
### Test
`$ make test(1-5)`

## Details (in spanish)
La fase 3 y final de la construcción de este generador de código intermedio 3CA, incluye las siguientes funcionalidades:
- Literales y comentarios: float, int y booleanos.
- Expresiones y operadores aritméticos.
- Expresiones booleanas formadas con operadores relacionales (con orden de precedencia).
- Sentencias: expresiones aritméticas, asignaciones, condicionales o iterativos.
- Tablas unidimensionales (arrays): float e int.
- Canvios de tipo: de float a int.
- Sentencias condicionales: if o ifelse.
- Sentencias iterativas: incondicional, con condición inicial, con condición final, indexadas.

Funcionalidades que faltan o no incluye:
- Switch statement: está la estructura pero no he implementado la generación del código intermedio.
- Strings: la primera fase incluía este tipo, pero por facilidad para el desarrollo de las otras fases no lo he seguido incorporando.
- Arrays e IDs booleanos.
- Las operaciones individuales de booleanos en algún momento da errores.
- Otras técnicas de optimización como loop unrolling.

Decisiones de diseño extras:
- He priorizado la modularidad de código para facilitar la compresión y el desarrollo.
- Para las fases 2 y 3, he descartado funcionalidades de la 1 que no se pedían para estas (strings, trigonometria, representación numérica), para centrarme principalmente en la generación de código intermedio y el backpatching respectivamente.
- Aunque con la fase 1 tenía archivo de log, para las fases 2 y 3 me resultaba más una carga que una ayuda, así que sabiendo que no es lo más correcto, he prescindido de este.
- La base del main y funciones de inicialización las he cogido y simplificado del código de la asignatura.
- El YYSTYPE está todo definido en el archivo datatypes.h, no en el archivo bison (syntactic.y).
- Como los arrays son float o int, en el cálculo de la posición, el tamaño de dato es 4.
- Para distinguir ID de array e ID normal, pongo -1 en el campo data.lenght si no es array.
- Hay ideas de estructura y código inspiradas en 2 fuentes: el libro de la asignatura y los repos de @tiredEsti (a mi gusto la mejor práctica pública de compiladores).
- El diseño de los quads, sigue el formato del libro de la asignatura: op, result, arg1, arg2.
- En la fase 3, he modificado la estructura de los quads para añadir el label y jugar con él para el backpatching.
- El diseño de las funciones de los quads está inspirado en el repo mencionado.

