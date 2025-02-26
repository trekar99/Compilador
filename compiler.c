/*######################################################################
#                           Compiladors
#                      Germán Puerto Rodríguez
#                             2024/25
######################################################################*/

#include <stdio.h>
#include <stdlib.h>
#include "compiler.h"

int main(int argc, char *argv[]){
	int error;
	if (argc == 3){ error = init_analisi_lexic(argv[1]);
		if(error == EXIT_SUCCESS){ error = init_analisi_sintactic(argv[2]);
			if(error == EXIT_SUCCESS){ error = analisi_semantic();
				error == EXIT_SUCCESS ? printf("\033[32;1mThe compilation has been successful\033[0m") : printf("\033[31;1mERROR \033[0m");
				error = end_analisi_sintactic();
				if(error == EXIT_FAILURE){printf("The output file can not be closed\n");}
				error = end_analisi_lexic();
				if(error == EXIT_FAILURE){printf("The input file can not be closed\n");}
			}
			else{printf("The output file %s can not be created\n",argv[2]);}
		}
		else{printf("The input file %s can not be opened\n",argv[1]);}
	}
	else{printf("\nUsage: %s INPUT_FILE OUTPUT_FILE\n",argv[0]);}
	return EXIT_SUCCESS;
}
