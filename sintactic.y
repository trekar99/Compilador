%{

	#include <stdio.h>
	#include <stdlib.h>
	#include "sintactic.h"
	extern FILE *yyout; 
	extern int yylineno; 
	extern int yylex();
	#include "./functions.h"
	#include "./symtab/symtab.h"

	extern int yyerror(char *explanation);
	char error_log[300];

%}

%code requires {
	#include "./symtab/datatypes.h"
}

%start program

%token ASSIGN ADD SUB MUL DIV MOD POW EOL COMMA IN_PAR OUT_PAR AND OR NOT EQ GT GE LT LE NE SIN COS TAN LEN SUBSTR PI E DEC BIN OCT HEX
%token <data> CONST ID BOOL BOOL_ID
%type <data> expression arithm arithm_l1 arithm_l2 arithm_l3 boolean boolean_l1 boolean_l2 boolean_l3

%%

program: statement_list

statement_list: statement_list statement | statement

statement: expression EOL				{
											printf("EXPRESSION: { type: %s, value: %s }\n", typeToString($1), valueToString($1));
											fprintf(yyout, "EXPRESSION: { type: %s, value: %s } \n", typeToString($1), valueToString($1)); 
										}
										

			| ID ASSIGN expression EOL  { 	
											if ( sym_lookup( $1.name, &$1 ) == SYMTAB_NOT_FOUND ) {
												sym_enter( $1.name, &$3 );
												printf("ASSIGNATION: { id: %s, type: %s, value: %s }\n", $1.name, typeToString($3), valueToString($3));
												fprintf(yyout, "ASSIGNATION: { id: %s, type: %s, value: %s } \n", $1.name, typeToString($3), valueToString($3));
											}
											else {
												sym_enter( $1.name, &$3 );
												printf("ASSIGNATION: { id: %s, type: %s, value: %s }\n", $1.name, typeToString($3), valueToString($3));
												fprintf(yyout, "ASSIGNATION: { id: %s, type: %s, value: %s } \n", $1.name, typeToString($3), valueToString($3)); 
											}
										}
			| DEC IN_PAR OUT_PAR EOL { setRepresentation(0); }
			| HEX IN_PAR OUT_PAR EOL { setRepresentation(1); }
			| BIN IN_PAR OUT_PAR EOL { setRepresentation(2); }
			| OCT IN_PAR OUT_PAR EOL { setRepresentation(3); }						
			| EOL { printf("\n"); }

expression: arithm | boolean 

arithm: arithm_l1 | arithm ADD arithm_l1 { if( add($1, $3, &$$) ) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the ADD operation... \033[0m" ); YYABORT; } }
			| arithm SUB arithm_l1 { if( sub($1, $3, &$$) ) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the SUB operation... \033[0m" ); YYABORT; } }
			| ADD arithm_l1 { $$ = $2; }
			| SUB arithm_l1 { if( negate($2, &$$) ) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the NEGATE operation... \033[0m" ); YYABORT; }}

arithm_l1: 	arithm_l2 | arithm_l1 MUL arithm_l2	{ if( mul($1, $3, &$$) ) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the MUL operation... \033[0m" ); YYABORT; }} 
				| arithm_l1 DIV arithm_l2 { if( division($1, $3, &$$) ) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the DIV operation... \033[0m" ); YYABORT; }}
				| arithm_l1 MOD arithm_l2 { if( mod($1, $3, &$$) ) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the MOD operation... \033[0m" ); YYABORT; }}

arithm_l2:	arithm_l2 POW arithm_l3 { if( power($1, $3, &$$) ) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the POW operation... \033[0m" ); YYABORT; }} | arithm_l3 

arithm_l3: 	IN_PAR arithm OUT_PAR { $$ = $2; } 
				| ID 			{ 
									if ( sym_lookup( $1.name, &$1 ) != SYMTAB_NOT_FOUND ) $$ = $1; 
									else {
										sprintf( error_log,"\033[31;1m SEMANTIC ERROR: ID ( %s ) not defined \033[0m", $1.name);
        								yyerror( error_log );
										YYABORT;
									} 
								}		
				| CONST 
				| SIN IN_PAR CONST OUT_PAR { if (trigonometric($3, &$$, 0)) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the SIN operation... \033[0m" ); YYABORT; } }
				| COS IN_PAR CONST OUT_PAR { if (trigonometric($3, &$$, 1)) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the COS operation... \033[0m" ); YYABORT; } }
				| TAN IN_PAR CONST OUT_PAR { if (trigonometric($3, &$$, 2)) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the TAN operation... \033[0m" ); YYABORT; } }

				| LEN IN_PAR ID OUT_PAR { 
											if ( sym_lookup( $3.name, &$3 ) != SYMTAB_NOT_FOUND ) { $$.type = INTEGER; $$.intVal = $3.length; }
											else {
												sprintf( error_log,"\033[31;1m SEMANTIC ERROR: ID ( %s ) not defined \033[0m", $3.name);
												yyerror( error_log );
												YYABORT;
											} 
										}
				| SUBSTR IN_PAR ID COMMA CONST COMMA CONST OUT_PAR { 
											if ( sym_lookup( $3.name, &$3 ) != SYMTAB_NOT_FOUND ) { 
												if( substr($3, &$$, $5.intVal, $7.intVal) ) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the SUBSTR operation... \033[0m" ); YYABORT; }
											}
											else {
												sprintf( error_log,"\033[31;1m SEMANTIC ERROR: ID ( %s ) not defined \033[0m", $3.name);
												yyerror( error_log );
												YYABORT;
											} 
										}
				| SUBSTR IN_PAR CONST COMMA CONST COMMA CONST OUT_PAR { if( substr($3, &$$, $5.intVal, $7.intVal) ) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the SUBSTR operation... \033[0m" ); YYABORT; }}
				| PI { $$.type = FLOAT; $$.floatVal = M_PI; }
				| E { $$.type = FLOAT; $$.floatVal = M_E; }

boolean:  boolean_l1 | boolean OR boolean_l1	{ $$.type = BOOLEAN; $$.boolVal = $1.boolVal || $3.boolVal;};

boolean_l1: boolean_l2 | boolean_l1 AND boolean_l2 { $$.type = BOOLEAN; $$.boolVal = $1.boolVal && $3.boolVal;};

boolean_l2: boolean_l3 | NOT boolean_l2 { $$.type = BOOLEAN; $$.boolVal = !($2.boolVal);};

boolean_l3: BOOL | BOOL_ID | IN_PAR boolean OUT_PAR	{$$ = $2;}
			| arithm EQ arithm	{ if( boolean($1, $3, &$$, 0) ) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the EQ operation... \033[0m" ); YYABORT; } }
			| arithm GT arithm 	{ if( boolean($1, $3, &$$, 1) ) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the GT operation... \033[0m" ); YYABORT; } }
			| arithm GE arithm	{ if( boolean($1, $3, &$$, 2) ) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the GE operation... \033[0m" ); YYABORT; } }
			| arithm LT arithm	{ if( boolean($1, $3, &$$, 3) ) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the LT operation... \033[0m" ); YYABORT; } }
			| arithm LE arithm	{ if( boolean($1, $3, &$$, 4) ) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the LE operation... \033[0m" ); YYABORT; } }
			| arithm NE arithm	{ if( boolean($1, $3, &$$, 5) ) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the NE operation... \033[0m" ); YYABORT; } }

%%

int init_analisi_sintactic(char* filename){
	int error = EXIT_SUCCESS; yyout = fopen(filename,"w");
	if (yyout == NULL){error = EXIT_FAILURE;} 
	return error;
}

int analisi_semantic(){
	int error; if (yyparse() == 0){error = EXIT_SUCCESS;}
	else {error = EXIT_FAILURE;} 
	return error;
}

int end_analisi_sintactic(){
	int error; error = fclose(yyout); if(error == 0){error = EXIT_SUCCESS;}
	else{error = EXIT_FAILURE;} return error;
}

int yyerror(char *explanation){fprintf(stderr,"Error: %s, in line %d \n",explanation,yylineno); return 0;}
