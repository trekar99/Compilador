/*######################################################################
#                           Compiladors
#                      Germán Puerto Rodríguez
#                             2024/25
######################################################################*/

#include "./symtab/datatypes.h"

/* toString operations*/
const char* typeToString(var v);
void setRepresentation(int code);
char* valueToString(var v);
int substr(var v, var *result, int ini, int length);

/* Arithmetic operations*/
int add(var v1, var v2, var *result);
int sub(var v1, var v2, var *result);
int mul(var v1, var v2, var *result);
int division(var v1, var v2, var *result);
int mod(var v1, var v2, var *result);
int power(var v1, var v2, var *result);
int negate(var v,var *result);

/* Trigonometric operation */
int trigonometric(var v, var *result, int code);

/* Boolean operation */
int boolean(var v1, var v2, var *result, int code);

/* Auxiliar */
char* itoa(int value, char* result, int base);
