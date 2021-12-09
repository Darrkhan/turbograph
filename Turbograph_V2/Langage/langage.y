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

%union {
  double valeur;
  char nom[50]; 
}

%token <valeur> NUM
%token <nom> VAR
%type <valeur> expr 
%token SIN
%token ASIN
%token SINH
%token COS
%token ACOS
%token COSH
%token TAN
%token ATAN
%token TANH
%token LOG
%token EXP
%token POW
%token PRINT
%token ASSIGN
%token DRAW
%token SUR
%token SUR1
%token SUR2
%token FCT
%token SQRT
%token ABS

%right POW
%right ADD SUB SUB2
%left MULT DIV

%%
bloc:  /* Epsilon */
     | bloc instruction '\n'   

instruction :   /* Epsilon, ligne vide */
            | VAR { fonction = $1; }  '(' VAR ')'  '=' expr { fonction = "main"; }
            | expr         {  }
            | PRINT expr   { add_instruction(PRINT); }
            | VAR '=' expr { add_instruction(ASSIGN, 0, $1); }
            | DRAW VAR '(' VAR ')' SUR NUM NUM { 
                                    add_instruction(FCT, 0, $2 );
                                    add_instruction(SUR1, $7);  
                                    add_instruction(SUR2, $8);
                                    add_instruction(DRAW);
                                    }                

expr:  NUM               { add_instruction (NUM, $1, "", fonction);  }
     | VAR               { add_instruction (VAR, 0, $1, fonction); }
     | SIN '(' expr ')'  { add_instruction (SIN, 0, "", fonction); }
     | ASIN '(' expr ')'  { add_instruction (ASIN, 0, "", fonction); }
     | SINH '(' expr ')'  { add_instruction (SINH, 0, "", fonction); }
     | COS '(' expr ')'  { add_instruction (COS, 0, "", fonction); }
     | ACOS '(' expr ')'  { add_instruction (ACOS, 0, "", fonction); }
     | COSH '(' expr ')'  { add_instruction (COSH, 0, "", fonction); }
     | TAN '(' expr ')'  { add_instruction (TAN, 0, "", fonction); }
     | ATAN '(' expr ')'  { add_instruction (ATAN, 0, "", fonction); }
     | TANH '(' expr ')'  { add_instruction (TANH, 0, "", fonction); }
     | LOG '(' expr ')'  { add_instruction (LOG, 0, "", fonction); }
     | EXP '(' expr ')'  { add_instruction (EXP, 0, "", fonction); }
     | '(' expr ')'      { $$ = $2; }
     | expr ADD expr     { add_instruction (ADD, 0, "", fonction); }
     | expr SUB expr     { add_instruction (SUB, 0, "", fonction); } 
     | SUB expr          { add_instruction (SUB2, 0, "", fonction); }  		
     | expr MULT expr    { add_instruction (MULT, 0, "", fonction); }		
     | expr DIV expr     { add_instruction (DIV, 0, "", fonction); }
     | expr POW expr     { add_instruction (POW, 0, "", fonction); }
     | SQRT '(' expr ')'  { add_instruction (SQRT, 0, "", fonction); }
     | ABS '(' expr ')'  { add_instruction (ABS, 0, "", fonction); }
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
    case SIN      : return "SIN";
    case ASIN      : return "ASIN";
    case SINH      : return "SINH";
    case COS      : return "COS";
    case ACOS      : return "ACOS";
    case COSH      : return "COSH";
    case TAN      : return "TAN";
    case ATAN      : return "ATAN";
    case TANH      : return "TANH";
    case LOG      : return "LOG";
    case EXP      : return "EXP";
    case POW      : return "POW";
    case DRAW     : return "DRAW";
    case FCT      : return "FCT";
    case SUR1      : return "SUR1";
    case SUR2      : return "SUR2";
    case SQRT     : return "SQRT";
    case ABS      : return "ABS";
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
    //cout << print_code(ins.code) << endl;

    if (trouve || ins.name == exec) { 
      trouve = true;
        switch (ins.code){
          case SUR1 :
            xmin = ins.value;
            //cout << xmin << endl;
          break;
          case SUR2 :
            xmax = ins.value;
            //cout << xmax << endl;
          break;
          case DRAW :
            for(double i = xmin; i <= xmax; i+=((xmax - xmin)/((xmax - xmin)*50))) {
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

        pile.push(r2-r1);
      break;
      case SUB2:
        r1 = pile.top();    // Rrécupérer la tête de pile;
        pile.pop();

        pile.push(-r1);
      break;
      case DIV:
        r1 = pile.top();    // Rrécupérer la tête de pile;
        pile.pop();

        r2 = pile.top();    // Rrécupérer la tête de pile;
        pile.pop();

        //if(r2 == 0) r2 = 0.00001;
        pile.push(r2/r1);
      break;
      case POW:
        r1 = pile.top();
        pile.pop();
        r2 = pile.top();
        pile.pop();
        pile.push(pow(r2,r1));
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
      case ASIN:
        r1 = pile.top();
        pile.pop();

        pile.push(asin(r1));
      break;
      case SINH:
        r1 = pile.top();
        pile.pop();

        pile.push(sinh(r1));
      break;
      case COS:
        r1 = pile.top();
        pile.pop();

        pile.push(cos(r1));
      break;
      case ACOS:
        r1 = pile.top();
        pile.pop();

        pile.push(acos(r1));
      break;
      case COSH:
        r1 = pile.top();
        pile.pop();

        pile.push(cosh(r1));
      break;
      case TAN:
        r1 = pile.top();
        pile.pop();

        pile.push(tan(r1));
      break;
      case ATAN:
        r1 = pile.top();
        pile.pop();

        pile.push(atan(r1));
      break;
      case TANH:
        r1 = pile.top();
        pile.pop();

        pile.push(tanh(r1));
      break;
      case LOG:
        r1 = pile.top();
        pile.pop();

        pile.push(log(r1));
      break;
      case EXP:
        r1 = pile.top();
        pile.pop();

        pile.push(exp(r1));
      break;
      case SQRT:
        r1 = pile.top();
        pile.pop();

        pile.push(sqrt(r1));
      break;
      case ABS:
        r1 = pile.top();
        pile.pop();

        pile.push(abs(r1));
      break;
    }
    ic++;
  }

  ofstream a("C:/Users/Administrateur/Documents/Turbograph_V2/Langage/points.txt", ios::app);
  if(a){
      a << variables["x"] << " " << pile.top() << ";" << fonction << endl;
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