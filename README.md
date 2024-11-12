# Compilador
A simple calculator compiler

## Pre-requisites
- Flex
- Bison
- GCC

## Files
- lexic.l: Flex file that defines the regular expressions for the lexer.
- syntactic.y: Bison grammar file that defines the grammar rules for the calculator.
- compiler.c & compiler.h: Main structure and functions of the compiler.
- functions.c & functions.h: Auxiliar functions for running the compiler.
- symtab/datatypes.h: Definition of types for symtab and grammar logic.

## Working with the compiler
### Build

`$ make`

### Run

`$ ./compiler INPUT_FILE OUTPUT_FILE`

### Clean

`$ make clean`

## Details
### Basics
- The program supports basic mathematical operations (+,-,*,/,**) and additionally trigonometric functions (sin,cos,tan) and string. Numerical values must be integers or floats
- Exponential numbers are also supported
- YYSTYPE defined as var in datatypes.h
- Bool can't be concatenate.
- Errors are visible in red and execution stops when there is one.

### Extras
- The calculator supports trigonometric functions (sin, cos, tan)
- Supports LEN string length function and substring extraction SUBSTR(string; start; length)
- Supports the use of default constants PI, E
- Allows representation in octal (OCT), binary (BIN), hexagesimal (HEX) or decimal mode, which is the default format (DEC)

