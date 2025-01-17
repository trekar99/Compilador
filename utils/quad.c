/*######################################################################
#                           Compiladors
#                      Germán Puerto Rodríguez
#                             2024/25
######################################################################*/

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include "../symtab/datatypes.h"

quad *quad_list;
int currQuad = 0;
int temp = 1;

void printQuads(){
	for (int i = 0; i < currQuad; i++) {
   		quad *q = &quad_list[i];
   		if (strcmp(q->op, ":=") == 0) printf("%d: %s := %s\n", i + 1, q->result, q->arg1);
		else if (strcmp(q->op, "PARAM") == 0) printf("%d: PARAM %s\n", i + 1, q->result);
		else if (strcmp(q->op, "CALL") == 0) printf("%d: CALL %s, %s\n", i + 1, q->result, q->arg1);
		else if ((strcmp(q->op, "LTI") == 0) || (strcmp(q->op, "LTF") == 0)) printf("%d: IF %s %s %s GOTO %s\n", i + 1, q->result, q->op, q->arg1, q->arg2);
		else if ((strcmp(q->op, "CHSI") == 0) || (strcmp(q->op, "CHSF") == 0)) printf("%d: %s := %s %s\n", i + 1, q->result, q->op, q->arg1);
		else if (strcmp(q->op, "I2F") == 0) printf("%d: %s := I2F %s\n", i + 1, q->result, q->arg1);
		else printf("%d: %s := %s %s %s\n", i + 1, q->result, q->arg1, q->op, q->arg2);
	}

	printf("%d: HALT\n", currQuad+1);
	
}


void addQuad(int num_args, ...) {
  va_list args;
  va_start(args, num_args);
  quad q;
  q.op = (char *)malloc(100);
  q.arg1 = (char *)malloc(100);
  q.arg2 = (char *)malloc(100);
  q.result = (char *)malloc(100);

  strcpy(q.op, va_arg(args, char*));
  strcpy(q.result, va_arg(args, char*));
  if (num_args > 2) strcpy(q.arg1, va_arg(args, char*));
  if (num_args > 3) strcpy(q.arg2, va_arg(args, char*));

  quad_list[currQuad] = q;
  currQuad++;
  va_end(args);
}

char *newTemp() {
  char tempString[50];
  sprintf(tempString, "$t%d", temp);
  temp++;
  char *tempPointer = tempString;
  return tempPointer;
}
