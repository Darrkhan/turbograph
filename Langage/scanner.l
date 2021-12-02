%option noyywrap

%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "parser.h"
%}

%option header-file="scanner.h"
%option outfile="scanner.cpp"

%%

[0-9]+(\.[0-9]*)?([Ee][+-]?[0-9]+)? {  yylval.valeur = atof(yytext); return NUM; }
\n     {  return '\n'; }
\r     { }
" "    { }
\t     { }
Sin|SIN|sin|sinus|Sinus|SINUS { return SIN;  }
Cos|COS|cos|cosinus|Cosinus|COSINUS { return COS;  }

x      {  return INC; }
[A-Za-z_][A-Za-z_0-9]* { strcpy( yylval.nom, yytext) ;  return VAR; }
[A-Za-z_][A-Za-z_0-9]*\(x\) { strcpy( yylval.nom, yytext) ;  return FCT; }

\+     {  return yytext[0];  }  // la même chose que return '+'  
"-"    {  return '-'; }
"*"    {  return '*'; }
"/"    {  return '/'; }
"="|"<-"    {  return '='; }
\(     {  return '('; }
\)     {  return ')'; }
.      {  printf ("Erreur lexicale : %s\n", yytext); return 0; }

%%
