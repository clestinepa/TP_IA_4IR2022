%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TP1 - ALGORITHME A* - APPLICATION AU TAQUIN %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Familiarisation avec le problème du Taquin 3×3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Quelle clause Prolog permettrait de représenter la situation finale du Taquin 4x4 ?

final_state([ [a, b,  c, d],
              [e, f, g, h],
              [i, j, k, l],
              [m, n, o, vide] ]).

% A quelles questions permettent de répondre les requêtes suivantes :

initial_state(Ini), nth1(L,Ini,Ligne), nth1(C,Ligne, d). % : Quelle est la place initiale (Ligne,Colonne]) de d ?
final_state(Fin), nth1(3,Fin,Ligne), nth1(2,Ligne,P). % : Quelle pièce a pour place finale [2,3] ([Ligne,Colonne]) ?

% Quelle requête Prolog permettrait de savoir si une pièce donnée P (ex : a) est bien placée dans U0 (par rapport à F) ?

coordonnees(Piece, Taquin, [L,C]) :- nth1(L, Taquin, Ligne), nth1(C, Ligne, Piece).

piece_bien_placee(Piece,Taquin) :- 
      final_state(Fin),
      coordonnees(Piece,Fin,Coordonnees),
      coordonnees(Piece,Taquin,Coordonnees).

initial_state(Ini), piece_bien_placee(Piece,Ini).

    % Version une seule ligne :

initial_state(Ini), final_state(Fin), nth1(L, Fin, Ligne), nth1(C, Ligne, Piece), nth1(L, Ini, Ligne), nth1(C, Ligne, Piece). %renvoie toutes les pièces bien placées :)


% Quelle requête permet de trouver une situation suivante de l'état initial du Taquin 3×3 (3 sont possibles) ?

initial_state(Ini), rule(_,_,Ini,Suivant).

% Quelle requête permet d'avoir ces 3 réponses regroupées dans une liste ?.

findall(Suivant, (initial_state(Ini), rule(_,_,Ini,Suivant)),States).

% Quelle requête permet d'avoir la liste de tous les couples [A, S] tels que S est la situation qui résulte de l'action A en U0 ?

rules_et_etats_suivant_possible(Taquin,DuoRuleState) :- findall([Rule,Suivant], rule(Rule,_,Taquin,Suivant),DuoRuleState).

initial_state(Ini), rules_et_etats_suivant_possible(Ini,DuoRuleState).

    % Version une seule ligne :

findall([Rule,Suivant], (initial_state(Ini), rule(Rule,_,Ini,Suivant)),DuoRuleState).


%%%%%%%%%%%%%%%%%%%%%%
% Implémentation de A*
%%%%%%%%%%%%%%%%%%%%%%

% Quelle taille de séquences optimales (entre 2 et 30 actions) peut-on générer avec chaque heuristique (H1, H2) ?
% Présenter les résultats sous forme de tableau.

%                  SEQUENCE (en nb de coups)
% Etats initiaux          H1        H2        
%       1                                                                                 
%       2                                                      
%       3                                                      
%       4                                                      
%       5                                                      
%       6                                                      

% Quelle longueur de séquence peut-on envisager de résoudre pour le Taquin 4x4 ?

% Le taquin 4x4 demande 16 pièce (on comptant le vide) à organiser contre seulement 9 pour le taquin 3x3
% Il contient donc presque 2 taquins qui sont en plus liés entre eux
% De plus, le nombre d'états possible est infiniment plus grand (400 000 contre 21 000 000 000 000)
% On peut donc envisager une longueur de séquence INTERMINAAABLE !
% Heureusement qu'avec d'autres heuristiques et contraintes (éviter de rompre les suites de pièce correcte, mettre les pièce dans le bon ordre une par une ect), on est capable de résoudre un 4x4, sinon c'est la loose.

% A* trouve-t-il la solution pour la situation initiale suivante ?

initial_state([ [a,b,c],
                [g,vide,d],
                [h,f,e] ]).
% Cette situation et la situation finale ne sont pas connexes : notre algorithme ne peut pas trouver de solution puisqu'il n'en existe pas
% L'algo tourne donc en boucle jusqu'à que les ~400 000 états possible soient étudiés (ça fait bcp d'états...)

% Quelle représentation de l’état du Rubik’s Cube et quel type d’action proposeriez-vous si vous vouliez appliquer A*?

% Tout d'abord, il y a 24 "pièces" différentes, 8 coins de 3 couleurs
%                                               12 arrêtes de 2 couleurs
%                                               4 centres de 1 couleur
% On peut modéliser une liste de 6 taquins représentant les faces du Rubik's Cube
% Les coins apparaissent donc dans 3 taquins différents, les arrêtes dans 2 et les centres dans un unique taquin
% La liste simulerait un Rubik's Cube que l'on tient toujours face à nous [Face,Haut,Bas,Gauche,Droite,Arrière] (à n'importe quel moment de l'algorithme Face correspond à Face initial)

% Ainsi, les actions qui s'offrent à nous sont les suivantes :
% Pour chaque ligne : gauche (pivoter la ligne vers la gauche) ou droite
%       Soit 2 actions pour 3 lignes : 6 actions de rotations horizontale
% Pour chaque colonne : haut (pivoter la colonne vers le haut) ou bas
%       Soit 2 actions pour 3 colonnes : 6 actions de rotations verticales
% Nous avons alors 12 actions de rotations possibles à chaque état

% A première vue, l'algo semble interminable mais nous n'allons évidemment pas l'implémenter pour vérifier ces dire :)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ALGO MINMAX - APPLICATION AU TICTACTOE %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Familiarisation avec le problème du TicTacToe 3×3
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Quelle interprétation donnez-vous aux requêtes suivantes :

situation_initiale(S), joueur_initial(J). % : Définit la situation initiale : J joue les croix et commence

situation_initiale(S), nth1(3,S,Lig), nth1(2,Lig,o). % : Un rond est placé en [3,2] sur un plateau vide

% Proposer des requêtes de tests unitaires pour chaque prédicat.

situation_terminale(_,[[x,o,x],[x,o,x],[o,x,o]]). % True
situation_terminale(_,[[x,o,_],[x,o,x],[o,x,o]]). % False

% M = [ [a,b,c],
%       [d,e,f],
%       [g,h,i] ]
alignement(Ali, [[a,b,c],[d,e,f],[g,h,i]]). % Donne bien tous les alignements attendus

alignement_gagnant([x,x,x], x). % True
alignement_perdant([x,x,x], x). % False
alignement_gagnant([o,o,o], x). % False
alignement_perdant([o,o,o], x). % True
alignement_gagnant([o,x,x], x). % False
alignement_perdant([o,x,x], x). % False


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Développement de l’heuristique h(Joueur, Situation)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Proposer d’autres tests unitaires pour vérifier qu’elle retourne bien les valeurs attendues
%    dans le cas d’une situation gagnante pour J (joueur au croix)
heuristique(x, [[x,o,x],[o,x,o],[x,o,o]], H). % H = 10000
heuristique(x, [[x,o,x],[o,x,o],[x,o,_]], H). % H = 10000

%    dans le cas d’une situation perdante pour J (joueur au croix)

heuristique(x, [[x,o,x],[o,o,x],[x,o,o]], H). % H = -10000

%    dans le cas d’une situation nulle (toutes les cases ont été jouées sans qu’aucune joueur n’ait gagné).

heuristique(x, [[x,o,x],[x,o,x],[o,x,o]], H). % H = 0


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Expérimentation et extensions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Quel est le meilleur coup à jouer et le gain espéré pour une profondeur d’analyse de 1, 2, 3, 4 , 5 , 6 , 7, 8, 9
% Expliquer les résultats obtenus pour 9 (toute la grille remplie).

% PROFONDEUR        1       2       3       4       5       6       7       8       9
% GAIN              4       1       3       1       3       1       2       0       0
% MEILLEUR COUP   [2,2]   [2,2]   [2,2]   [2,2]   [2,2]   [2,2]   [2,2]   [3,3]   [3,3]

% Si l'on joue bien, on ne peut jamais perdre au tictactoe ! Et ça, notre algo ne s'en rend compte seulement qu'avec une profondeur nécessairement grande : à partir de 8 
% C'est pour cela que le meilleur coup change, l'algo comprend que la situation mènera forcément à une égalité, le coup importe donc peu
% L'implémentation prend donc le dernier coup [3,3] possible.

% Comment ne pas développer inutilement des situations symétriques de situations déjà développées ?

% Il suffirait de stocker les situations et lors du développement, les comparer entièrement aux situations déjà connues.
% "Entièrement" car il faut comparer ses miroirs, ses rotations, ... Toutes les situations qui sont similaire en terme de possibilités
% Néanmoins, nous perdrons surement en optimisation vu la quantité de situations symétriques à vérifier.

% Que faut-il reprendre pour passer au jeu du puissance 4 ?

% Changements : plateau 9*9 + alignement de 4 + gravité
% Nous devrons reprendre alignement : plateau plus grand + devoir contrôler la longueur des alignements (les diagonales peuvent atteindre 9 alors que seulement 4 pions suffisent)
% Il faudra rajouter la contrainte de la case inferieure non vide pour les coups possibles.

% Comment améliorer l’algorithme en élaguant certains coups inutiles (recherche Alpha-Beta) ?

% On réduirait les coups inutile : réduire la taille de l'arbre de dérivation et donc sa durée de création.