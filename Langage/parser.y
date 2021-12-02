%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <iostream>
  #include <fstream>
  #include <cmath>   
  #include <map>
  #include <string>

  using namespace std;

  extern int yylex ();
  extern char* yytext;
  extern FILE* yyin;
  int yyerror(char *s);

  // Déclaration de la map qui associe les noms des variables à leur valeur
  map<string,double> variables ;
  //map<string,double> fonction ;


  double i = -1000;
%}

%defines "parser.h"
%output "parser.cpp"

%union {
  double valeur;
  char nom[50];
  //double tableau[1000];
}

%token <valeur> NUM
%token <nom> VAR
%token <nom> FCT
%token <nom> INC
%type <valeur> expr 
//%type <tableau> newexpr 
%token SIN
%token COS

%left '+' '-'
%left '*' '/'

%%
ligne:  /* Epsilon */
     | ligne instruction '\n'   

instruction : expr         { printf("Résultat du calcul : %g\n", $1); }
            | VAR '=' expr { variables[$1]=$3;  
                             printf ("Affectation de %g à %s\n", $3, $1);
                           }


            /*| newexpr      { printf("Résultat du calcul : %g\n", $1); } //à voir, à modifier pour afficher le format de newexpr
            | FCT '=' newexpr { fonction[$1]=$3;  
                                printf ("Affectation de %g à %s\n", $3, $1);

                            }
newexpr: FCT             { try { 
                                  $$ = fonction.at($1);
                               }
                           catch(...){
                               printf ("La variable %s est utilisée mais jamais initialisée\n",$1);
                               fonction[$1]=0;
                               $$ = 0;
                               } 
                         }*/


expr:  NUM               { $$ = $1; }
     | VAR               { try { 
                                  $$ = variables.at($1);
                               }
                           catch(...){
                               printf ("La variable %s est utilisée mais jamais initialisée\n",$1);
                               variables[$1]=0;
                               $$ = 0.;
                               } 
                          }
     | SIN '(' expr ')'  { $$ = sin($3); printf ("sin(%g) = %g\n", $3, $$ ); 
                            ofstream a("/home/darrkhan/turbograph/Langage/aled.txt", ios::app);
                            if(a){
                              a << i/100 << " " << sin(i/100) << endl;
                            }
                          }
     | COS '(' expr ')'  { $$ = cos($3); printf ("cos(%g) = %g\n", $3, $$ ); }
     | '(' expr ')'      { $$ = $2; }
     | expr '+' expr     { $$ = $1 + $3; printf ("%g + %g = %g\n", $1, $3, $$ );}
     | expr '-' expr     { $$ = $1 - $3; printf ("%g - %g = %g\n", $1, $3, $$ );}   		
     | expr '*' expr     { $$ = $1 * $3; printf ("%g * %g = %g\n", $1, $3, $$ );}		
     | expr '/' expr     { $$ = $1 / $3; printf ("%g / %g = %g\n", $1, $3, $$ );}    
     | INC               {
                           $$ = i/100;
                         }
%%

int yyerror(char *s) {					
    printf("%s : %s\n", s, yytext);
}

int main(int argc, char **argv) {
  printf("Calculette V1.0\n");

  ofstream a("/home/darrkhan/turbograph/Langage/aled.txt");
  for(i = -1000; i < 1000; i++){
    yyin = fopen( "/home/darrkhan/turbograph/Langage/test.txt", "r" );
    yyparse();
  }				

  return 0;
}
