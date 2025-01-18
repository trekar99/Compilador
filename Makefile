######################################################################
#                           Compiladors
#                      Germán Puerto Rodríguez
#                             2024/25
######################################################################

# General defines
CC = gcc
LEX = flex
YACC = bison

# Link flex
LIB = -lfl -lm

INLEX = lexic.l
INYACC = syntactic.y

OBJ = lexic.o syntactic.o compiler.o functions.o symtab.o quad.o
 
SRC = compiler.c utils/functions.c symtab/symtab.c utils/quad.c
SRCL = lexic.c
SRCY = syntactic.c

BIN = compiler
LOG = log.txt

LFLAGS = -n -o $*.c
YFLAGS = -d -v -o $*.c
CFLAGS = -ansi -Wall -g -std=c99

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

test1: 
	./$(BIN) inputs/test.txt $(LOG)
test2:
	./$(BIN) inputs/test2.txt $(LOG)
