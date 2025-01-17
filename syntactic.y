/*######################################################################
#                           Compiladors
#                      Germán Puerto Rodríguez
#                             2024/25
######################################################################*/

%{

	#include <stdio.h>
	#include <stdlib.h>
	#include "syntactic.h"
	extern FILE *yyout; 
	extern int yylineno; 
	extern int yylex();
	#include "./utils/functions.h"
	#include "./utils/quad.h"
	#include "./symtab/symtab.h"	

	extern int yyerror(char *explanation);
	char error_log[300];

%}

%code requires {
	#include "./symtab/datatypes.h"
}

%start program

%token ASSIGN ADD SUB MUL DIV MOD POW EOL IN_PAR OUT_PAR DO DONE
%token <data> CONST ID REPEAT
%type <data> expression arithm arithm_l1 arithm_l2 arithm_l3 

%%

program: statement_list

statement_list: statement_list statement | statement | statement_list repeat_statement_end;

repeat_statement_start: REPEAT expression {
												if($2.type == FLOAT) { yyerror("\033[31;1m SEMANTIC ERROR: loop expression NOT an integer... \033[0m" ); YYERROR; }

												// 	fprintf(flog, "Line %d, LOOP START\n", yylineno); 
												// 	yylineno++;
												// 	$$ = $2;
												// 	$$.ctr = (char *)malloc(100);
												// 	strcpy($$.ctr, newTemp());
												// 	addQuad(2, $$.ctr, "0");
												// 	$$.repeat = currQuad +1;
												// }
										}

repeat_statement_end: repeat_statement_start DO EOL statement_list DONE {
											// fprintf(flog, "Line %d, LOOP END\n", yylineno); 
											
											// SE LA PELA EL STATEMENT_LIST SOLO SE ENCARGA DEL GOTO
											// if($1.type == UNDEFINED){}
											// else if($4.type == UNDEFINED){
											// 	$$.type = UNDEFINED;
											// 	yyerror("SEMANTIC ERROR: Error in loop error detected.\n");
											// } else{
											// 	if($1.type == INTEGER) addQuad(4, $1.ctr, "ADDI", $1.ctr, "1");
											// 	else addQuad(4, $1.ctr, "ADDF", $1.ctr, "1");
												
											// 	char str[20];
											// 	sprintf(str, "%d", $1.repeat);
											// 	if ($1.type == INTEGER)	{
											// 		addQuad(4, $1.ctr, "LTI", $1.place, str);
											// 	} else {
											// 		addQuad(4, $1.ctr, "LTF", $1.place, str);
											// 	}
											// }
											addQuad(1, "LTI");
										} 


statement: ID EOL						{
											if(sym_lookup($1.name, &$1) == SYMTAB_NOT_FOUND) { yyerror( "\033[31;1m SEMANTIC ERROR: variable NOT FOUND... \033[0m" ); YYERROR; } 
											else { 
												printf("EXPRESSION: { type: %s, value: %s }\n", typeToString($1), valueToString($1));
												fprintf(yyout, "EXPRESSION: { type: %s, value: %s } \n", typeToString($1), valueToString($1)); 

												addQuad(2, "PARAM", $1.name);
												//fprintf(flog, "Line %d, PARAM %s set\n", yylineno, $1.name);

												addQuad(3, "CALL", $1.type == INTEGER  ? "PUTI" : "PUTF", "1");
												// 	fprintf(flog, "Line %d, calling PUTI/PUTF\n", yylineno);
											}
										}
										

			| ID ASSIGN expression EOL  { 	
											sym_enter( $1.name, &$3 );
											printf("ASSIGNATION: { id: %s, type: %s, value: %s }\n", $1.name, typeToString($3), valueToString($3));
											fprintf(yyout, "ASSIGNATION: { id: %s, type: %s, value: %s } \n", $1.name, typeToString($3), valueToString($3)); 

											addQuad(3, ":=", $1.name, $3.dest);
										}				
			| EOL { printf("\n"); }

expression: arithm 

arithm: arithm_l1 | arithm ADD arithm_l1 { if( add($1, $3, &$$) ) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the ADD operation... \033[0m" ); YYABORT; } }
			| arithm SUB arithm_l1 { if( sub($1, $3, &$$) ) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the SUB operation... \033[0m" ); YYABORT; } }
			| ADD arithm_l1 { $$ = $2; }
			| SUB arithm_l1 { 
								if( negate($2, &$$) ) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the NEGATE operation... \033[0m" ); YYABORT; }

								// PLACE SON PARA LOS TMPS
								// $$.place = (char *)malloc(5);
								// strcpy($$.place, newTemp());
								// addQuad(3, $$.place, $2.type == INTEGER ? "CHSI" : "CHSF", $2.place);
							}

arithm_l1: 	arithm_l2 | arithm_l1 MUL arithm_l2	{ if( mul($1, $3, &$$) ) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the MUL operation... \033[0m" ); YYABORT; }} 
				| arithm_l1 DIV arithm_l2 { if( division($1, $3, &$$) ) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the DIV operation... \033[0m" ); YYABORT; }}
				| arithm_l1 MOD arithm_l2 { if( mod($1, $3, &$$) ) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the MOD operation... \033[0m" ); YYABORT; }}

arithm_l2:	arithm_l2 POW arithm_l3 { if( power($1, $3, &$$) ) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the POW operation... \033[0m" ); YYABORT; }} | arithm_l3 

arithm_l3: 	IN_PAR arithm OUT_PAR { $$ = $2; } 
				| ID 			{ 
									if ( sym_lookup( $1.name, &$1 ) == SYMTAB_NOT_FOUND ) { 
										sprintf( error_log,"\033[31;1m SEMANTIC ERROR: ID ( %s ) not defined \033[0m", $1.name);
        								yyerror( error_log );
										YYABORT;
									}
									else {
										$$.type = $1.type; 
										$$.dest = (char *)malloc(50); 
										strcpy($$.dest, $1.name); 
										$$.name = (char *)malloc(100);
										strcpy($$.name, $1.name); 
									}
								}		
				| CONST 

%%

int init_analisi_sintactic(char* filename){
	int error = EXIT_SUCCESS; yyout = fopen(filename,"w");
	if (yyout == NULL){error = EXIT_FAILURE;} 
	return error;
}

int analisi_semantic(){
	quad_list = (quad *)malloc(sizeof(quad) * 500);
	int error; if (yyparse() == 0){error = EXIT_SUCCESS;}
	else {error = EXIT_FAILURE;} 
	printQuads();

	return error;
}

int end_analisi_sintactic(){
	int error; error = fclose(yyout); if(error == 0){error = EXIT_SUCCESS;}
	else{error = EXIT_FAILURE;} return error;
}

int yyerror(char *explanation){fprintf(stderr,"Error: %s, in line %d \n",explanation,yylineno); return 0;}
