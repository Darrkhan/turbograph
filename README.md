# turbograph
CIR3 project

## Prérequis
* __QT 6.0.0__
* __Make__
* __Flex__
* __Bison__

## Initialisation du projet

* #### il faut vérifier/changer les chemin d'accés dans les différents fichiers :
  * Dans mainwindow.cpp :
    *  __Ligne 68__
    *  __Ligne 79__ (/!\Veuillez respecter la forme __"\\\\"__ entre les noms de dossier)
    *  __Ligne 81__
  * Dans Langage/Langage.y : 
    *  __Ligne 385__
    *  __Ligne 399__
    *  __Ligne 419__
 * #### Une fois les accés changer, il faut executer make dans le dossier Langage
 * #### Dans __QT__, il faut lancer le projet (le plus simle et de double cliquer sur le .pro du dossier); il faut ensuite le build (*si il y a des erreurs les chemins d'accés sont surement pas bon*)
 * ### Initialisation terminée. 

## Utilisation :

### 1. Lancer le programme, vous allez vous retrouver avec une fenetre  contenant :   

  * Une zone de graph.  
  * Une zone de texte.  
  * Des checkbox permettant l'affichage ou non des courbes.  
  * L'affichage de la position du curseur sur la zone de graph.

### 2. Vous devez définir votre fonction pour commencer.  
                                           exemple : "f(x) = sin(x)"  
Vous pouvez en définir plusieurs (/!\ plus vous en définirais plus le programme seras potentiellement lent.)  
     
### 3. Secondement, vous pouvez tracer votre fonction précedemment définie grace a la commande :   
                                      dessiner FCT  sur  Intervalmin   Intervalmax  
                                           exemple : "dessiner f(x) sur 0 10"   
Vous pouvez afficher plusieurs courbes, et changer l'apparition ou non des 5 premières, la casse est ignorée.
### 4. Vous appuyez ensuite sur tracer (deux fois) et vos courbes s'afficheront (*en cas de bug réappuyer sur tracer*)  

/!\ plus l'interval est grand plus la compilation sera longue.  


### Les fonctions:  
* Sinus
  * sin(expression)
* Cosinus
  * cos(expression)
* Tangente
  * tan(expression) 
* Sinus hyperbolique
  * sinh(expression)
* Cosinus hyperbolique
  * cosh(expression)
* Tangente hyperbolique
  * tanh(expression) 
* Arcsin
  * arcsin(expression) 
* Arccos
  * arccos(expression)
* Arctan
  * arctan(expression)
* sqrt (racine carré)
  * sqrt(expression)
* pow (puissance)
  * (expression) ^ (expression)
* multiplication
  * (expression) * (expression)
* addition
  * (expression) + (expression)
* soustraction
  * (expression) - (expression)
* division
  * (expression) / (expression)
* absolue
  * abs(expression)
