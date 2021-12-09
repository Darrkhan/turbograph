%option noyywrap
%option caseless

%{
  #include <stdio.h>
  #include <stdlib.h>
  #include "langage.bison.hpp"
%}

%%
//Déclaration de tous nos mots clés permettant l'executions de nos fonctions.
[-]?[0-9]+(\.[0-9]*)?([Ee][+-]?[0-9]+)? { // s'il s'agit d'un nombre on le stocke dans le champ "valeur"
                                      yylval.valeur = atof(yytext);
                                      return NUM;
                                    }
\n     {  return '\n'; }
\r     { }
" "    { }
\t     { }
sinus|sin { return SIN;  }
arcsinus|arcsin|asin { return ASIN; }
cosinus|cos { return COS; }
arccosinus|arccos|acos { return ACOS; }
tangente|tan { return TAN; }
arctangente|arctan|atan { return ATAN; }
sinushyperbolique|sinhyperbolique|sinush|sinh { return SINH; }
cosinushyperbolique|coshyperbolique|cosinush|cosh {return COSH; }
tangentehyperbolique|tanhyperbolique|tangenteh|tanh { return TANH; }
logarithme|log { return LOG; }
exponentielle|exp { return EXP; }
imprime|impr { return PRINT; }
dessiner|dessine { return DRAW; }
sur|dans { return SUR; } 
"^"|pow { return POW; }
sqrt { return SQRT; }
abs { return ABS; }

[A-Za-z_][A-Za-z_0-9]* { // s'il s'agit d'une variable, on stocke son nom dans le champ "nom"
                         strcpy( yylval.nom, yytext) ;
                         return VAR;
                       }

\+     {  return ADD; }  
"-"    {  return SUB; }
"*"    {  return MULT; }
"/"    {  return DIV; }
"="|"<-"    {  return '='; }
\(     {  return '('; }
\)     {  return ')'; }
<<EOF>>  { printf("\nLe programme est correct!\n"); return 0; }
.      {  printf ("Erreur lexicale : %s\n", yytext); return 0; }

%%
