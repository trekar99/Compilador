/*######################################################################
#                           Compiladors
#                      Germán Puerto Rodríguez
#                             2024/25
######################################################################*/

%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "./symtab/symtab.h"
#include "syntactic.h"
extern FILE *yyin;

%}

%option yylineno
%option noyywrap
%option noinput
%option nounput

letter 				[a-zA-Z]
digit 				[0-9]

identifier  		{letter}({letter}|{digit})*
	
integer		 		{digit}({digit})*
real 				{integer}\.{digit}*([eE][-+]?{digit}+)?
boolean				true|false
string			    \".[^"\n]*\"
comment				\/\/.*\n|\#.*\n
multicomment		\/\*[^*]*\*+([^\/][^*]*\*+)*\/

EOL      		 	"\n"

%%
"repeat"  {return REPEAT;}
"do"      {return DO;}
"done"    {return DONE;}

"+"                 { return ADD; }
":="                { return ASSIGN; }
"-"                 { return SUB; }
"*"                 { return MUL; }
"/"                 { return DIV; }
"%"              	{ return MOD; }
"**"                { return POW; }
"("					{ return IN_PAR; }
")"					{ return OUT_PAR; }

{real}         		{ yylval.data.type = FLOAT; yylval.data.floatVal = atof(yytext); yylval.data.length = yyleng; return CONST; }
{integer} 			{ yylval.data.type = INTEGER; yylval.data.intVal = atoi(yytext); yylval.data.length = yyleng; return CONST; }

{identifier} 		{ 
						yylval.data.name = (char *)malloc(sizeof(char)*yyleng); strncpy(yylval.data.name,yytext,yyleng);
						yylval.data.length = yyleng; 

						var aux;
						if (sym_lookup(yytext, &aux) == SYMTAB_NOT_FOUND) return ID;
						else return ID;
						
					}

{comment}			{ printf( "%s", yytext ); }
{multicomment}		{}


"\n"				{ return EOL; }

" "					{}

.		    		{ printf( " Unknown character. \n" ); }

%%

int init_analisi_lexic(char *file_name){
	yyin=fopen(file_name,"r");
	return (yyin == NULL) ? EXIT_FAILURE : EXIT_SUCCESS;
}

int end_analisi_lexic(){ return (fclose(yyin) == 0) ? EXIT_SUCCESS : EXIT_FAILURE; }

/*
	yylex(): rutina del analisi léxico.
	yytext: contiene el token.
	yyleng: longitud del token.
	yylval: valor del token.
	yyin: fichero input. Default: *yyin=stdin;
	yyout: fichero output. Default: *yyout=stdout;
	
	yyparse(): solicita nuevo token
*/
