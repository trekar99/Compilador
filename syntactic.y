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
	#include "./functions.h"
	#include "./symtab/symtab.h"

	#include <stdarg.h>
	

	extern int yyerror(char *explanation);
	char error_log[300];


	quad *quad_list;
	int currQuad = 0;
	int temp = 1;

	void addQuad(int num_args, ...);	
	void printQuads();

%}

%code requires {
	#include "./symtab/datatypes.h"
}

%start program

%token ASSIGN ADD SUB MUL DIV MOD POW EOL IN_PAR OUT_PAR REPEAT DO DONE
%token <data> CONST ID 
%type <data> expression arithm arithm_l1 arithm_l2 arithm_l3 

%%

program: statement_list

statement_list: statement_list statement | statement | statement_list repeat_statement_start | repeat_statement_start | statement_list repeat_statement_end;

repeat_statement_start: REPEAT expression {
												// if($2.type == FLOAT){
												// 	$$.type = UNDEFINED;
												// 	yyerror("SEMANTIC ERROR: Loop initiation error detected. Invalid operation for float\n");
												// 	yylineno++;
												// } else {

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

											addQuad(2, ":=", $1.name);
										}				
			| EOL { printf("\n"); }

expression: arithm 

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

void printQuads(){
	//fprintf(flog, "Line %d, Printing intermediate code\n", yylineno);

	for (int i = 0; i < currQuad; i++) {
   		quad *q = &quad_list[i];
   		if (strcmp(q->op, ":=") == 0) printf("%d: %s := PORCELANOSA\n", i + 1, q->result);
		else if (strcmp(q->op, "PARAM") == 0) printf("%d: PARAM %s\n", i + 1, q->result);
		else if (strcmp(q->op, "CALL") == 0) printf("%d: CALL %s, %s\n", i + 1, q->result, q->arg1);
   		// } else if (strcmp(q->one, "CALL") == 0){
   		// 	printf("%d: CALL %s, %s\n", i+1, q->two, q->three);
   		// } else if (strcmp(q->two, "I2F") == 0){
   		// 	printf("%d: %s := I2F %s\n", i+1, q->one, q->three);
   		// } else if (strcmp(q->two, "CHSI" ) == 0){
   		// 	printf("%d: %s := CHSI %s\n", i+1, q->one, q->three);
   		// } else if (strcmp(q->two, "CHSF" ) == 0){
   		// 	printf("%d: %s := CHSF %s\n", i+1, q->one, q->three);
   		// } else if (q->two[0] == 'L' && q->two[1] == 'T'){
   		// 	printf("%d: IF %s %s %s GOTO %s\n", i+1, q->one, q->two, q->three, q->four);
   		// } else if (q->one[0] == '$'){
   		// 	printf("%d: %s := %s %s %s\n", i+1, q->one, q->two, q->three, q->four);
   		// } else {
   		// 	printf("%d: %s := %s\n", i+1, q->one, q->two);
   		// }

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
//   if (num_args > 0) strcpy(q.op, va_arg(args, char*));
//   if (num_args > 1) strcpy(q.arg1, va_arg(args, char*));
//   if (num_args > 2) strcpy(q.arg2, va_arg(args, char*));
//   if (num_args > 3) strcpy(q.result, va_arg(args, char*));
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
