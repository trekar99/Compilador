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

## Details
- Support for Arithmetic Expressions: Handles integer and real literals, identifiers, and arithmetic operators.
- Variable Assignments: Allows assignment of values to variables.
- Basic Control Flow Statements: Implements unconditional iterative statements (repeat...do).
- Type Handling: Supports explicit type changes and one-dimensional arrays.
- Code Generation: Generates three-address code (C3A) for expressions and control statements.
- Error Reporting: Provides detailed error messages for lexical, syntactic, or semantic errors.
- Comment Support: Allows single-line (//) and multi-line (//) comments in the source code.
- No Pointers: Does not support pointers, simplifying the code generation process.

