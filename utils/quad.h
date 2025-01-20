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

/* Backpatching */
list* makelist(int i);
list* merge(list *l1, list *l2);
void backpatch(list *p, int l);
