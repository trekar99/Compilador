%{

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "./symtab/symtab.h"

%}

%option yylineno
%option noyywrap
%option noinput
%option nounput

%%

":="                { printf( " = " ); }
"**"                { printf( " ^ " ); }
"+"                 { printf( " + " ); }
"-"                 { printf( " - " ); }
"*"                 { printf( " * " ); }
"/"                 { printf( " / " ); }
"mod"               { printf( " mod " ); }
"sqrt"              { printf( " sqrt " ); }

.		    { printf( " Carácter irreconocible. " ); }

%%
