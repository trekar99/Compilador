######################################################################
# Compiladors 2024/25
# Germán Puerto
######################################################################

# General defines
CC = gcc
LEX = flex
YACC = bison

# Link flex
LIB = -lfl -lm

INLEX = lexic.l
INYACC = syntactic.y

OBJ = lexic.o syntactic.o compiler.o functions.o symtab.o
 
SRC = compiler.c functions.c symtab/symtab.c
SRCL = lexic.c
SRCY = syntactic.c

BIN = compiler

LFLAGS = -n -o $*.c
YFLAGS = -d -v -o $*.c
CFLAGS = -ansi -Wall -g 

OTHERS = syntactic.h syntactic.output
######################################################################
all : $(SRCL) $(SRCY)
	$(CC) -o $(BIN) $(CFLAGS) $(SRCY) $(SRC) $< $(LIB)
$(SRCL) : $(INLEX)
	$(LEX) $(LFLAGS) $<
$(SRCY) : $(INYACC)
	$(YACC) $(YFLAGS) $<
clean :
	rm -f $(BIN) $(OBJ) $(SRCL) $(SRCY) $(OTHERS)
