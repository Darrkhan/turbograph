%{
  #include <stdio.h>
  #include <stdlib.h>
  #include <cmath>   
  #include <map>
  #include <vector>
  #include <string>
  #include <iostream>
  #include <stack>
  #include <fstream>


  using namespace std;

  extern int yylex ();
  extern char* yytext;
  extern FILE* yyin;
  int yyerror(char *s);

  class instruction{
  public:
    instruction (const int &c, const double &v=0, const string &n="") {code = c; value = v; name = n;};  
    int code; 
    double value;     // éventuellement une valeur si besoin
    string name;      // ou une référence pour la table des données 
  };

  // Déclaration de la map qui associe
  // les noms des variables à leur valeur
  // (La table de symboles)
  map<string,double> variables;
  int ic = 0;
  string fonction = "main";
  // Cette map sert à stocker les adresses associées aux labels (GoTo).
  // Pour info, il est possible de faire un saut vers une étiquette
  // qui n'est pas encore déclarée (Saut vers le futur)
  // En gros, les sauts GoTo ne se font pas uniquement vers l'arrière.
  // Je vous laisse gérer les problèmes créés par le Goto :
  // - Saut vers une étiquette inexistante (ni avant, ni après)
  // - Duplication de labels (Déterminisme !!!)
  // Ne parlons pas, comme dans l'exmeple, des sauts de blocs de déclarations, 
  // ou des bloc entremêlés, ou... ou ...
  // Vous avez compris pourquoi il est banni ?
  map<string,int> adresses;

  
  // Structure pour accueillir le code généré 
  // (sone de code ou code machine ou assembleur)
  map <string, vector <instruction>> code_genere; 

  map <string, map<double, double>> tableauFctPoints;   

  // Remarquez les paramètres par défaut pour faciliter les appels depuis la grammaire
  int add_instruction(const int &c, const double &v=0, const string &n="", const string &fonction="main") {
      code_genere[fonction].push_back(instruction(c,v,n)); 
      ic++;
      return 0; 
   }; 


void execution ( string fonction,
                 map<string, vector <instruction>> &param_code_genere, 
                 map<string,double> &variables );

%}

%code requires
  {
    typedef struct adr {
        int jmp;  // adresse du jmp
        int jc;  // adrese  du jc
    } type_adresse;
  }

%union {
  double valeur;
  char nom[50];
  type_adresse adresse;  
}

%token <valeur> NUM
%token <nom> VAR
%type <valeur> expr 
%token SIN
%token COS
%token <adresse> SI
%token ALORS
%token SINON
%token FINSI
%token SUP
%token PRINT
%token ASSIGN
%token GOTO
%token <nom> LABEL
%token JMP
%token JMPCOND
%token DRAW
%token SUR
%token SUR1
%token SUR2
%token FCT

%right ADD SUB   // N'oubliez pas de remettre left !
%left MULT DIV

%%
bloc:  /* Epsilon */
     | bloc label instruction '\n'   

label : // Epsilon
      | LABEL ':'  { // Lorsque je rencontre un label
                     // je stocke le numéro d'instruction actelle
                     // dans la table des adresses. C'est tout!   
                     adresses [$1] = ic;}

instruction :   /* Epsilon, ligne vide */
            | VAR { fonction = $1; }  '(' VAR ')'  '=' expr { fonction = "main"; }
            | expr         {  }
            | PRINT expr   { add_instruction(PRINT); }
            | VAR '=' expr { add_instruction(ASSIGN, 0, $1); }
            | GOTO LABEL   {  // J'insère un JMP vers une adresse que je ne connais pas encore.
                              // J'utiliserai la table des adresses pour la récupérer lors de l'exécution
                              add_instruction(JMP, -999, $2); 
                           }
            | SI '(' condition ')' '\n' { // Je sauvegarde l'endroit actuel pour revenir mofifier l'adresse 
                                          // lorsqu'elle sera connue (celle du JC)
                                          $1.jc = ic;
                                          add_instruction(JMPCOND); }
              ALORS '\n'
                bloc                    { // Je sauvegarde l'endroit actuel pour revenir mofifier l'adresse 
                                          // lorsqu'elle sera connue (celle du JMP)
                                          $1.jmp = ic;
                                          add_instruction(JMP);
                                          // Je mets à jour l'adresse du saut conditionnel
                                          code_genere[fonction][$1.jc].value = ic;
                                        }
              SINON '\n' 
                bloc                                  
              FINSI                     { // Je mets à jour l'adresse du saut inconditionnel
                                          code_genere[fonction][$1.jmp].value = ic;} 
              | DRAW VAR '(' VAR ')' SUR NUM NUM { 
                                    add_instruction(FCT, 0, $2 );
                                    add_instruction(SUR1, $7);  
                                    add_instruction(SUR2, $8);
                                    add_instruction(DRAW);
                                    }                

expr:  NUM               { add_instruction (NUM, $1, "", fonction);   }
     | VAR               { add_instruction (VAR, 0, $1, fonction);  }
     | SIN '(' expr ')'  { add_instruction (SIN, 0, "", fonction); }
     | COS '(' expr ')'  { add_instruction (COS, 0, "", fonction); }
     | '(' expr ')'      { $$ = $2; }
     | expr ADD expr     { add_instruction (ADD, 0, "", fonction); }
     | expr SUB expr     { add_instruction (SUB, 0, "", fonction); }   		
     | expr MULT expr    { add_instruction (MULT, 0, "", fonction); }		
     | expr DIV expr     { add_instruction (DIV, 0, "", fonction);  }   


condition :  expr          {}
          |  expr SUP expr {}
%%

int yyerror(char *s) {					
    printf("%s : %s\n", s, yytext);
}


// Petite fonction pour mieux voir le code généré 
// (au lieu des nombres associés au tokens)
string print_code(int ins) {
  switch (ins) {
    case ADD      : return "ADD";
    case MULT     : return "MUL";  
    case SUB      : return "SUB";
    case DIV      : return "DIV";  
    case NUM      : return "NUM";
    case VAR      : return "VAR";
    case PRINT    : return "OUT";
    case ASSIGN   : return "MOV";
    case JMP      : return "JMP";
    case JMPCOND  : return "JC ";
    case SIN      : return "SIN";
    case COS      : return "COS";
    case DRAW     : return "DRAW";
    case FCT      : return "FCT";
    case SUR1      : return "SUR1";
    case SUR2      : return "SUR2";
    default : return "";
  }
}
void execution_fonction (string exec, map<string, vector <instruction>> &param_code_genere, map <string, double> &variables){
  double xmin, xmax;

  bool trouve = false;

  int ic = 0;  // compteur instruction

  auto code_genere = param_code_genere["main"];

  while (ic < code_genere.size()){   // tant que nous ne sommes pas à la fin du programme
    auto ins = code_genere[ic];
    cout << print_code(ins.code) << endl;


    if (trouve || ins.name == exec) { 
      trouve = true;
        switch (ins.code){
          case SUR1 :
            xmin = ins.value;

            cout << xmin << endl;

            

          break;
          case SUR2 :
            xmax = ins.value;
            
            cout << xmax << endl;

            

          break;
          case DRAW :
            

            for(double i = xmin; i <= xmax; i+=((xmin+xmax)/100)) {
              variables["x"] = i;
              execution(exec, param_code_genere, variables);
            }
            trouve = false;

          break;
      }
    }
    ic++;
  }
}

// Fonction qui exécute le code généré sur un petit émulateur
void execution ( string fonction,
                 map<string, vector <instruction>> &param_code_genere, 
                 map<string,double> &variables )
{
  //printf("\n------- Exécution du programme ---------\n");
  stack<double> pile;

  int ic = 0;  // compteur instruction
  double r1, r2;  // des registres

  auto code_genere = param_code_genere[fonction];

  //printf("C'est quoi la réponse à la grande question sur la vie, l'univers et le reste ?\n");

  while (ic < code_genere.size()){   // tant que nous ne sommes pas à la fin du programme
    auto ins = code_genere[ic];

    switch (ins.code){
      case FCT : 
        execution_fonction (ins.name, param_code_genere, variables );
        

      break;
      case ADD:
        r1 = pile.top();    // Rrécupérer la tête de pile;
        pile.pop();

        r2 = pile.top();    // Rrécupérer la tête de pile;
        pile.pop();
        
        pile.push(r1+r2);
        

      break;
      case MULT:
        r1 = pile.top();    // Rrécupérer la tête de pile;
        pile.pop();

        r2 = pile.top();    // Rrécupérer la tête de pile;
        pile.pop();

        pile.push(r1*r2);
        

      break;
      case SUB:
        r1 = pile.top();    // Rrécupérer la tête de pile;
        pile.pop();

        r2 = pile.top();    // Rrécupérer la tête de pile;
        pile.pop();

        pile.push(r1-r2);
        

      break;
      case DIV:
        r1 = pile.top();    // Rrécupérer la tête de pile;
        pile.pop();

        r2 = pile.top();    // Rrécupérer la tête de pile;
        pile.pop();

        if(r2 = 0) r2 = 0.00001;
        pile.push(r1/r2);
        

      break;
      case ASSIGN:
        r1 = pile.top();    // Rrécupérer la tête de pile;
        pile.pop();
        variables[ins.name] = r1;
        

      break;

      case PRINT:
        r1 = pile.top();    // Rrécupérer la tête de pile;
        pile.pop();
        cout << "$ " << r1 << endl; 
        

      break;

      case NUM:   // pour un nombre, on empile
        pile.push(ins.value);
        

      break;

      case VAR:    // je consulte la table de symbole et j'empile la valeur de la variable
        // Si elle existe bien sur... 
        try {
          pile.push(variables.at(ins.name));
          
        }
        catch(...) {
          variables[ins.name] = 0;
          pile.push(variables.at(ins.name));
        
        }

      break;
      case SIN:
        r1 = pile.top();
        pile.pop();

        pile.push(sin(r1));
        

      break;
      case COS:
        r1 = pile.top();
        pile.pop();

        pile.push(cos(r1));
        

      break;
    }
    ic++;
  }
  
  cout << "x = " << variables["x"] << endl;
  cout << "resultat = " << pile.top() << endl;

  ofstream a("C:/Users/Administrateur/Documents/Turbograph_V2/Langage/points.txt", ios::app);
  if(a){
      a << variables["x"] << " " << pile.top() << endl;
  }
  else{
      cout << "ERREUR: Impossible d'ouvrir le fichier en lecture." << endl;
  }
}

int main(int argc, char **argv) {
  printf("-----------------\nLangage V3.0 / Deep Thought\n");

  // Code pour traiter un fichier au lieu de l'entrée clavier
  
  yyin = fopen( "C:/Users/Administrateur/Documents/Turbograph_V2/Langage/test.txt", "r" );

  yyparse();						


  for (auto f : code_genere) {
    cout << "code de la fonction " << f.first << endl;

    for (int i = 0; i < f.second.size(); i++){
      auto instruction = f.second [i];
      cout << i 
          << '\t'
          << print_code(instruction.code) 
          << '\t'
          << instruction.value 
          << '\t' 
          << instruction.name 
          << endl;
    }
  }

  
  ofstream a("C:/Users/Administrateur/Documents/Turbograph_V2/Langage/points.txt");

  execution("main", code_genere, variables);

  return 0;
}