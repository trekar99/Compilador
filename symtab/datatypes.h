#include <stdbool.h>
#include <stdio.h>
#include <string.h>

#ifndef VAR_TYPE
#define VAR_TYPE
typedef enum
{
    INTEGER,
    FLOAT,
    STRING,
    BOOLEAN
} datatype;

typedef struct var
{
    char * name;
    union {
        int intVal;
        float floatVal;
        char * stringVal;
        bool boolVal;
    };
    datatype type;
    int length;

    // Auxiliar variables for temp managing
    char * dest;
} var;


typedef struct quad
{
    char * op; 
    char * arg1; 
    char * arg2; 
    char * result;   
} quad;

typedef union{ var data; }YYSTYPE;

#define M_PI 3.14159265358979323846264338327950288
#define M_E 2.718281828459045

#endif
