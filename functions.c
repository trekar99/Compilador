/*######################################################################
#                           Compiladors
#                      Germán Puerto Rodríguez
#                             2024/25
######################################################################*/

#include "./symtab/datatypes.h"
#include "./functions.h"
#include "./quad.h"
#include <stdlib.h>
#include <math.h>
#define degToRad(angleInDegrees) ((angleInDegrees) * M_PI / 180.0)
#define radToDeg(angleInRadians) ((angleInRadians) * 180.0 / M_PI)
extern void yyerror( const char* );

/* toString operations*/
int representation = 0;
const char* typeToString(var v) {
   switch (v.type) 
   {
         case INTEGER: return "Integer";
         case FLOAT: return "Float";
         case STRING: return "String";
         case BOOLEAN: return "Boolean";
         default: return 0;
   }

}

void setRepresentation(int code) { representation = code; }
	
char * valueToString(var v) {
   char* value = (char *) malloc(200);
   switch (v.type) 
   {
         case INTEGER: 
            if(representation == 0) {
                  sprintf(value, "%i", v.intVal); break;
            }
            else if(representation == 1) {
                  sprintf(value, "%x", v.intVal); break;
            }
            else if(representation == 2) {
                  itoa(v.intVal, value, 2); break;
            }
            else if(representation == 3) {
                  sprintf(value, "%o", v.intVal); break;
            }
         case FLOAT: sprintf(value, "%g", v.floatVal); break;
         case STRING: sprintf(value, "%s", v.stringVal); break;
         case BOOLEAN: sprintf(value, "%s", (v.boolVal == true) ? "true" : "false"); break;
         default: return 0;
   }
   return value;
}

int substr(var v, var *result, int ini, int length) {
      if (v.stringVal == 0 || v.length == 0 || v.length < ini || v.length < (ini + length)) {
            yyerror( "\033[31;1m SEMANTIC ERROR: incorrect substr function parameters. \033[0m" ); 
            return 1; 
      }
      else {
            result->type = STRING;
            result->stringVal = (char *) malloc( length );
            strncpy(result->stringVal, v.stringVal + ini, length); 
            result->stringVal[length] = '\0';
      }
      return 0;
}

/* Arithmetic operations*/
int add(var v1, var v2, var *result) {
      
      result->dest = (char *)malloc(100);
      if (v1.type == INTEGER && v2.type == INTEGER) {
            result->type = INTEGER;
            strcpy(result->dest, newTemp());
            addQuad(4, "ADDI", result->dest, v1.dest, v2.dest);
      }
      else if ((v1.type == INTEGER || v1.type == FLOAT) && (v2.type == INTEGER || v2.type == FLOAT)) {
            result->type = FLOAT;

            char * chTemp = (char *)malloc(100);
            strcpy(chTemp, newTemp());
            if (v1.type == INTEGER) {
                  addQuad(3, "I2F", chTemp, v1.dest);
                  v1.type = FLOAT;
                  strcpy(v1.dest, chTemp);
            } 
            if (v2.type == INTEGER) {
                  addQuad(3, "I2F", chTemp, v2.dest);
                  v2.type = FLOAT;
                  strcpy(v2.dest, chTemp);
            }
            strcpy(result->dest, newTemp());
		addQuad(4, "ADDF", result->dest, v1.dest, v2.dest);
      }
      else { yyerror( "\033[31;1m SEMANTIC ERROR: adding incompatible types. \033[0m" ); return 1; }

      return 0;
}

int sub(var v1, var v2, var *result) {
      result->dest = (char *)malloc(100);
      if (v1.type == INTEGER && v2.type == INTEGER) {
            result->type = INTEGER;
            strcpy(result->dest, newTemp());
            addQuad(4, "SUBI", result->dest, v1.dest, v2.dest);
      }
      else if ((v1.type == INTEGER || v1.type == FLOAT) && (v2.type == INTEGER || v2.type == FLOAT)) {
            result->type = FLOAT;

            char * chTemp = (char *)malloc(100);
            strcpy(chTemp, newTemp());
            if (v1.type == INTEGER) {
                  addQuad(3, "I2F", chTemp, v1.dest);
                  v1.type = FLOAT;
                  strcpy(v1.dest, chTemp);
            } 
            if (v2.type == INTEGER) {
                  addQuad(3, "I2F", chTemp, v2.dest);
                  v2.type = FLOAT;
                  strcpy(v2.dest, chTemp);
            }
            strcpy(result->dest, newTemp());
		addQuad(4, "SUBF", result->dest, v1.dest, v2.dest);
      }
      else { yyerror( "\033[31;1m SEMANTIC ERROR: adding incompatible types. \033[0m" ); return 1; }

      return 0;
}
 
int mul(var v1, var v2, var *result) {
      if (v1.type == FLOAT || v2.type == FLOAT) {
            result->type = FLOAT;

            if (v1.type == FLOAT && v2.type == INTEGER) result->floatVal = v1.floatVal * v2.intVal;  
            else if (v1.type == INTEGER && v2.type == FLOAT) result->floatVal = v1.intVal * v2.floatVal;  
            else if (v1.type == FLOAT && v2.type == FLOAT) result->floatVal = v1.floatVal * v2.floatVal;  
            else {
                  yyerror( "\033[31;1m SEMANTIC ERROR: multiplying a FLOAT with an incompatible type. \033[0m" ); 
                  return 1;
            }
      }

      else if (v1.type == INTEGER && v2.type == INTEGER) {
            result->type = INTEGER;
            strcpy(result->dest, newTemp());
            addQuad(4, "MULI", result->dest, v1.dest, v2.dest);
      }
      else {
            yyerror( "\033[31;1m SEMANTIC ERROR: multiplying incompatible types. \033[0m" ); 
            return 1;
      }

      return 0;
}

int division(var v1, var v2, var *result) {
      if (v1.type == FLOAT || v2.type == FLOAT) {
            result->type = FLOAT;

            if (v1.type == FLOAT && v2.type == INTEGER) result->floatVal = v1.floatVal / v2.intVal;  
            else if (v1.type == INTEGER && v2.type == FLOAT) result->floatVal = v1.intVal / v2.floatVal;  
            else if (v1.type == FLOAT && v2.type == FLOAT) result->floatVal = v1.floatVal / v2.floatVal;  
            else {
                  yyerror( "\033[31;1m SEMANTIC ERROR: dividing a FLOAT with an incompatible type. \033[0m" ); 
                  return 1;
            }
      }

      else if (v1.type == INTEGER && v2.type == INTEGER) {
            result->intVal = v1.intVal / v2.intVal;
            result->type = INTEGER;
      }
      else {
            yyerror( "\033[31;1m SEMANTIC ERROR: dividing incompatible types. \033[0m" ); 
            return 1;
      }

      return 0;
}

int mod(var v1, var v2, var *result) {
      if (v1.type == FLOAT || v2.type == FLOAT) {
            result->type = FLOAT;

            if (v1.type == FLOAT && v2.type == INTEGER) result->floatVal = fmod( v1.floatVal, v2.intVal );  
            else if (v1.type == INTEGER && v2.type == FLOAT) result->floatVal = fmod( v1.intVal, v2.floatVal );  
            else if (v1.type == FLOAT && v2.type == FLOAT) result->floatVal = fmod( v1.floatVal, v2.floatVal );  
            else {
                  yyerror( "\033[31;1m SEMANTIC ERROR: moduling a FLOAT with an incompatible type. \033[0m" ); 
                  return 1;
            }
      }

      else if (v1.type == INTEGER && v2.type == INTEGER) {
            result->intVal = fmod( v1.intVal, v2.intVal );  
            result->type = INTEGER;
      }
      else {
            yyerror( "\033[31;1m SEMANTIC ERROR: moduling incompatible types. \033[0m" ); 
            return 1;
      }

      return 0;
}

int power(var v1, var v2, var *result) {
      if (v1.type == FLOAT || v2.type == FLOAT) {
            result->type = FLOAT;

            if (v1.type == FLOAT && v2.type == INTEGER) result->floatVal = pow( v1.floatVal, v2.intVal );  
            else if (v1.type == INTEGER && v2.type == FLOAT) result->floatVal = pow( v1.intVal, v2.floatVal );  
            else if (v1.type == FLOAT && v2.type == FLOAT) result->floatVal = pow( v1.floatVal, v2.floatVal );  
            else {
                  yyerror( "\033[31;1m SEMANTIC ERROR: powering a FLOAT with an incompatible type. \033[0m" ); 
                  return 1;
            }
      }

      else if (v1.type == INTEGER && v2.type == INTEGER) {
            result->intVal = pow( v1.intVal, v2.intVal );  
            result->type = INTEGER;
      }
      else {
            yyerror( "\033[31;1m SEMANTIC ERROR: powering incompatible types. \033[0m" ); 
            return 1;
      }

      return 0;
}

int negate(var v, var *result) {
      if(v.type == INTEGER) {
        result->type = INTEGER;
        result->intVal = - v.intVal;

      }
      else if ( v.type == FLOAT ){
            result->type = FLOAT;
            result->floatVal = - v.floatVal;
      }
      else {
            yyerror( "\033[31;1m SEMANTIC ERROR: negating incompatible types. \033[0m" ); 
            return 1;
      }

      return 0;
}

/* Trigonometric operation */
int trigonometric(var v, var *result, int code) {

      int num = 0;

      result->type = FLOAT;

      if (v.type == FLOAT) { num = (v.floatVal); }
      else if (v.type == INTEGER) { num = (v.intVal); }
      else {
            yyerror( "\033[31;1m SEMANTIC ERROR: making trigonometric of incompatible types. \033[0m" ); 
            return 1;
      }

      if (code == 0) result->floatVal = (float)((int)(sin(degToRad(num)) * (100000)) / 100000.0);   
      else if (code == 1) result->floatVal = (float)((int)(cos(degToRad(num)) * (100000)) / 100000.0);   
      else if (code == 2) result->floatVal = (float)((int)(tan(degToRad(num)) * (100000)) / 100000.0);   

    return 0;
}

/* Boolean operation */
int boolean(var v1, var v2, var *result, int code) {
      result->type = BOOLEAN;

      float v1_f, v2_f;
      if (v1.type == INTEGER) v1_f = (float)v1.intVal;
      else if (v1.type == FLOAT) v1_f = v1.floatVal;
      else if (v1.type == BOOLEAN) v1_f = v1.boolVal;
     
      if (v2.type == INTEGER) v2_f = (float)v2.intVal;
      else if (v2.type == FLOAT) v2_f = v2.floatVal;
      else if (v2.type == BOOLEAN) v2_f = v2.boolVal;
      else {
            yyerror( "\033[31;1m SEMANTIC ERROR: boolean operation of incompatible types. \033[0m" ); 
            return 1;
      }

      if (code == 0) result->boolVal = v1_f == v2_f;
      else if (code == 1) result->boolVal = v1_f > v2_f;
      else if (code == 2) result->boolVal = v1_f >= v2_f;
      else if (code== 3) result->boolVal = v1_f < v2_f;
      else if (code == 4) result->boolVal = v1_f <= v2_f;
      else if (code == 5) result->boolVal = v1_f != v2_f;
     
      return 0;
}

/* Auxiliar */
char* itoa(int value, char* result, int base) {
		if (base < 2 || base > 36) { *result = '\0'; return result; }

		char* ptr = result, *ptr1 = result, tmp_char;
		int tmp_value;

		do {
			tmp_value = value;
			value /= base;
			*ptr++ = "zyxwvutsrqponmlkjihgfedcba9876543210123456789abcdefghijklmnopqrstuvwxyz" [35 + (tmp_value - value * base)];
		} while ( value );

		if (tmp_value < 0) *ptr++ = '-';
		*ptr-- = '\0';
		while(ptr1 < ptr) {
			tmp_char = *ptr;
			*ptr--= *ptr1;
			*ptr1++ = tmp_char;
		}
		return result;
}
