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
INYACC = sintactic.y

OBJ = lexic.o sintactic.o compiler.o functions.o symtab.o
 
SRC = compiler.c functions.c symtab/symtab.c
SRCL = lexic.c
SRCY = sintactic.c

BIN = compiler

LFLAGS = -n -o $*.c
YFLAGS = -d -v -o $*.c
CFLAGS = -ansi -Wall -g 

OTHERS = sintactic.h sintactic.output
######################################################################
all : $(SRCL) $(SRCY)
	$(CC) -o $(BIN) $(CFLAGS) $(SRCY) $(SRC) $< $(LIB)
$(SRCL) : $(INLEX)
	$(LEX) $(LFLAGS) $<
$(SRCY) : $(INYACC)
	$(YACC) $(YFLAGS) $<
clean :
	rm -f $(BIN) $(OBJ) $(SRCL) $(SRCY) $(OTHERS)
