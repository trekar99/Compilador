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

%token ASSIGN ADD SUB MUL DIV MOD POW EOL END IN_PAR OUT_PAR 
%token DO DONE IF THEN ELSE FI WHILE UNTIL FOR IN RANG AND NOT OR
%token <data> CONST ID REPEAT BOOL BOOLOP
%type <data> expression arithm arithm_l1 arithm_l2 arithm_l3 repeat_statement_start statement statement_list M N indexed_statementStart
%type <data> boolean_op1 boolean_op2 boolean_op3 boolean_arithmetic boolean 

%%

program: statement_list {backpatch($1.nextlist, currQuad);}

statement_list: //statement_list M statement { backpatch($1.nextlist, $2.repeat); $$.nextlist = $3.nextlist; }
				statement_list statement {backpatch($2.nextlist, currQuad+1);} 
				| statement {$$.nextlist = $1.nextlist;} | statement_list repeat_statement_end 

repeat_statement_start: REPEAT arithm {
												if($2.type == FLOAT) { yyerror("\033[31;1m SEMANTIC ERROR: loop expression NOT an integer... \033[0m" ); YYERROR; }

												$$ = $2;
												$$.control = (char *)malloc(100);
												strcpy($$.control, newTemp());
												addQuad(3, ":=", $$.control, "0");
												$$.repeat = currQuad + 1;
										}

repeat_statement_end: repeat_statement_start DO EOL statement_list DONE {
											addQuad(4, $1.type == INTEGER ? "ADDI" : "ADDF", $1.control, $1.control, "1"); // Index++
												
											char str[20];
											sprintf(str, "%d", $1.repeat);
											addQuad(4, $1.type == INTEGER ? "LTI" : "LTF", $1.control, $1.dest, str);
										} 


statement: ID EOL						{
											if(sym_lookup($1.name, &$1) == SYMTAB_NOT_FOUND) { yyerror( "\033[31;1m SEMANTIC ERROR: variable NOT FOUND... \033[0m" ); YYERROR; } 
											else { 
												fprintf(yyout, "EXPRESSION: { type: %s, value: %s } \n", typeToString($1), valueToString($1)); 

												addQuad(2, "PARAM", $1.name);
												addQuad(3, "CALL", $1.type == INTEGER  ? "PUTI" : "PUTF", "1");
											}
										}
			| ID ASSIGN expression EOL  { 	
											$3.name = (char *)malloc(100);
											strcpy($3.name, $1.name);
											sym_enter( $1.name, &$3 );
											fprintf(yyout, "ASSIGNATION: { id: %s, type: %s, value: %s } \n", $1.name, typeToString($3), valueToString($3)); 

											addQuad(3, ":=", $1.name, $3.dest);
										}			

			| IF IN_PAR boolean OUT_PAR THEN EOL M statement_list FI EOL { backpatch($3.truelist, $7.repeat); $$.nextlist = merge($3.falselist, $8.nextlist); }
			| IF IN_PAR boolean OUT_PAR THEN EOL M statement_list N ELSE M statement_list FI {
																					backpatch($9.nextlist, currQuad + 1);
																					backpatch($3.truelist, $7.repeat);
																					backpatch($3.falselist, $11.repeat);
																					list * temp = merge($8.nextlist, $9.nextlist);
																					$$.nextlist = merge(temp, $12.nextlist);
																				}	
			| WHILE IN_PAR M boolean OUT_PAR DO EOL M statement_list DONE EOL {
				backpatch($9.nextlist, $3.repeat);
				backpatch($4.truelist, $8.repeat);
				$$.nextlist = $4.falselist;
				char * aux = malloc(sizeof(char)*10);
				sprintf(aux, "%d", $3.repeat);
				addQuad(2, "GOTO", aux);
				free(aux);
			}
			| DO EOL M statement_list UNTIL IN_PAR boolean OUT_PAR EOL { backpatch($7.truelist, $3.repeat); $$.nextlist = merge($7.falselist, $4.nextlist); }
			| indexed_statementStart DO EOL statement_list DONE EOL	{
				yylineno++;
				addQuad(4, "ADDI", $1.name, $1.name, "1");
				char * aux = malloc(sizeof(char)*10);
				sprintf(aux, "%d", $1.repeat);
				addQuad(2, "GOTO", aux);
				char * aux2 = malloc(sizeof(char)*12);
				sprintf(aux2, "%d", currQuad + 1);
				quad_list[$1.repeat].label = malloc(sizeof(char)*100+1);
				strcpy(quad_list[$1.repeat].label , aux2);

				free(aux);
				free(aux2);
			}
																							
										
			| EOL {}

indexed_statementStart: FOR ID IN arithm RANG arithm {
	if($2.type != INTEGER){ yyerror("SEMANTIC ERROR: Loop initialization, invalid float operation.\n"); YYABORT; } 
	else { addQuad(3, ":=", $2.name, $4.dest); $$.dest = $4.dest; $$.repeat = currQuad; $$.name = $2.name; addQuad(4, "IF", $2.name, "LEI", $6.dest); }
};

M: { $$.repeat = currQuad + 1; };
N: { $$.nextlist = makelist(currQuad); addQuad(1, "GOTO");};


expression: arithm | boolean

arithm: arithm_l1 | arithm ADD arithm_l1 { if( add($1, $3, &$$) ) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the ADD operation... \033[0m" ); YYABORT; } }
			| arithm SUB arithm_l1 { if( sub($1, $3, &$$) ) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the SUB operation... \033[0m" ); YYABORT; } }
			| ADD arithm_l1 { $$ = $2; }
			| SUB arithm_l1 { if( negate($2, &$$) ) { yyerror( "\033[31;1m SEMANTIC ERROR: something happened in the NEGATE operation... \033[0m" ); YYABORT; } }

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
										
										$$.name = (char *)malloc(100);
										strcpy($$.name, $1.name); 

										if($$.length > 0) {
											char * chTemp = (char *)malloc(100);
											strcpy(chTemp, newTemp());

											char posToStr[20];
											sprintf(posToStr, "%d", $$.length);

											addQuad(4, "MULI", chTemp, posToStr, "4");		// Index * ByteNum

											char * resultTemp = (char *)malloc(100);
											strcpy(resultTemp, newTemp());
											addQuad(4, "ADDI", resultTemp, "1", chTemp);		// ++Base

											
											strcpy($$.dest, resultTemp);
										}
										else {
											$$.dest = (char *)malloc(50); 
											strcpy($$.dest, $1.name); 
										}
									}
								}		
				| CONST 

boolean: boolean_op1 | boolean OR M boolean_op1		{ 
	
	$$.dest = (char *)malloc(10);
	$$.type = BOOLEAN;
	strcpy($$.dest, newTemp());
	backpatch($1.falselist, $3.repeat);
	$$.truelist = merge($1.truelist, $4.truelist);
	$$.falselist = $4.falselist;
};

boolean_op1: boolean_op2 | boolean_op1 AND M boolean_op2 {
	$$.dest = (char *)malloc(10);
	$$.type = BOOLEAN;
	strcpy($$.dest, newTemp());
	backpatch($1.truelist, $3.repeat);
	$$.truelist = $4.truelist;
	$$.truelist = merge($1.falselist, $4.falselist);
};

boolean_op2: boolean_op3 | NOT boolean_op2 { $$ = $2; $$.truelist = $2.falselist; $$.falselist = $2.truelist; }

boolean_op3: boolean_arithmetic | IN_PAR boolean OUT_PAR	{ $$ = $2; }
	| BOOL 	{ 
		$$.dest = (char *)malloc(10);
		$$.type = BOOLEAN;
		strcpy($$.dest, $1.dest);
		
		if (strcmp($1.dest, "TRUE") == 0) $$.truelist = makelist(currQuad);
		else $$.falselist = makelist(currQuad);
		addQuad(1, "GOTO");
	}
	/*| B_ID	{	
		if(sym_lookup($1.name, &$1) == SYMTAB_NOT_FOUND) {
			yyerror("SEMANTIC ERROR: VARIABLE NOT FOUND\n");errflag = 1; YYERROR;
		}
		else { $$.type = $1.type; $$.value=$1.value; $$.place = $1.place;} 
	};*/

boolean_arithmetic: arithm BOOLOP arithm 	{
	int aux = currQuad +1;
	$$.truelist = makelist(currQuad);
	$$.falselist = makelist(aux);
	char buffer[100];
	sprintf(buffer, $2.dest);
	strcat(buffer, ($1.type == INTEGER && $3.type == INTEGER) ? "I" : "F");
	addQuad(4, "IF", $1.dest, buffer, $3.dest);
	addQuad(1, "GOTO");
};


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

int yyerror(char *explanation){fprintf(stderr,"Error: \033[31;1m %s \033[0m, in line %d \n",explanation,yylineno); return 0;}
