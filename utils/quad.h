/*######################################################################
#                           Compiladors
#                      Germán Puerto Rodríguez
#                             2024/25
######################################################################*/

#include "../symtab/datatypes.h"

/* Quads operations*/
void addQuad(int num_args, ...);	
void printQuads();

extern quad *quad_list;
extern int temp;
extern int currQuad;

/* Temps operations*/
char *newTemp();
