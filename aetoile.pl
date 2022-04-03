%*******************************************************************************
%                                    AETOILE
%*******************************************************************************

/*
Rappels sur l'algorithme

- structures de donnees principales = 2 ensembles : P (etat pendants) et Q (etats clos)
- P est dedouble en 2 arbres binaires de recherche equilibres (AVL) : Pu et Pf

   Pu est l'ensemble des etats pendants (pending states), ordonnes selon
   f croissante (h croissante en cas d'egalite de f). Il permet de trouver
   rapidement le prochain etat a developper (celui qui a f(U) minimum).

   Pf est le meme ensemble mais ordonne lexicographiquement (selon la donnee de
   l'etat). Il permet de retrouver facilement n'importe quel etat pendant

   On gere les 2 ensembles de fa�on synchronisee : chaque fois qu'on modifie
   (ajout ou retrait d'un etat dans Pu) on fait la meme chose dans Pf.

   Q est l'ensemble des etats deja developpes. Comme Pf, il permet de retrouver
   facilement un etat par la donnee de sa situation.
   Q est modelise par un seul arbre binaire de recherche equilibre.

Predicat principal de l'algorithme :

   aetoile(Pu,Pf,Q)

   - reussit si Pu est vide ou bien contient un etat minimum terminal
   - sinon on prend un etat minimum U, on genere chaque successeur S et les valeurs g(S) et h(S)
	 et pour chacun
		si S appartient a Q, on l'oublie
		si S appartient a Pf (etat deja rencontre), on compare
			g(S)+h(S) avec la valeur deja calculee pour f(S)
			si g(S)+h(S) < f(S) on reclasse S dans Pu avec les nouvelles valeurs
				g et f
			sinon on ne touche pas a Pu
		si S est entierement nouveau on l'insere dans Pu et dans Pf
	- appelle recursivement etoile avec les nouvelles valeurs NewPF, NewPf, NewQs

*/

%*******************************************************************************

:- ['avl.pl'].       % predicats pour gerer des arbres bin. de recherche
:- ['taquin.pl'].    % predicats definissant le systeme a etudier

%*******************************************************************************

main :-
    initial_state(Ini),

    G0 is 0,
    heuristique(Ini, H0),

    F0 is G0 + H0,

    empty(Pf0),
    empty(Pu0),
    empty(Q0),

    insert([[F0,H0,G0], Ini], Pf0, Pf1),
    insert([Ini, [F0,H0,G0], nil, nil] , Pu0, Pu1),

    aetoile(Pf1, Pu1, Q0)
.

affiche_ligne([]) :-
    true
.
affiche_ligne([vide|L_T]) :-
    write("  "),
    affiche_ligne(L_T)
.
affiche_ligne([L_H|L_T]) :-
    L_H \= vide,
    write(L_H),
    write(" "),
    affiche_ligne(L_T)
.
affiche_taquin([]) :- true.
affiche_taquin([S_H|S_T]) :-
    write(" "),
    affiche_ligne(S_H),
    write("\n"),
    affiche_solution(S_T)
.

% Affichage de l'état initial
affiche_solution(State, Qs) :-
    initial_state(State),
    !
.

affiche_solution(State, Qs) :-
    suppress([State, Father, Dir], Qs, _),
    write(Dir),
    write("\n"),
    %affiche_taquin(State),
    affiche_solution(Father, Qs)
.

%*******************************************************************************

expand(State, NextStates) :-
    findall([S, Dir], rule(Dir, _, State, S), NextStates)
.

loop_successor([], Pf, Pf, Pu, Pu, _, _, _) :-
    true
.

loop_successor([H|T], Pf1, Pf3, Pu1, Pu3, Qs, G, Father) :-
    process_successor(H, Pf1, Pf2, Pu1, Pu2, Qs, G, Father),
    loop_successor(T, Pf2, Pf3, Pu2, Pu3, Qs, G, Father)
.


% Successeur qui appartient à Qs
% Inutile de traiter
process_successor([State,_], Pf, Pf, Pu, Pu, Qs, _, _) :-
    belongs(State, Qs)
.

% Successeur qui n'appartient pas à Qs
% Successeur qui n'appartient pas à Pu
% On l'ajoute dans Pu et Pf avec son coût actuel
process_successor([State, Dir], Pf1, Pf2, Pu1, Pu2, Qs, G, Father) :-
    not(belongs(State, Qs)),
    not(belongs([State, _, _, _], Pu1)),
    heuristique(State, H),
    F is G + H,
    insert([State, [F, H, G], Father, Dir], Pu1, Pu2),
    insert([[F, H, G], State], Pf1, Pf2)
.

% Successeur qui appartient à Pu
% Successeur qui a un coût plus élevé que les estimations précédentes
% On ne fait rien
process_successor([State, _], Pf, Pf, Pu, Pu, _, G, _) :-
    belongs([State, [_,_,G_old], _, _], Pu),
    G >= G_old % On peut comparer les G car l'heuristique reste la même pour un même état
.

% Successeur qui appartient à Pu
% Successeur qui a un coût moins élevé que les estimations précédentes
% On le supprime de Pu et Pf puis on le réinsère
process_successor([State, Dir], Pf1, Pf3, Pu1, Pu3, _, G, Father) :-
    suppress([State, [F_old, H_old, G_old], _, _], Pu1, Pu2),
    suppress([[F_old, H_old, G_old], State], Pf1, Pf2),
    G < G_old,
    F is G + H,
    insert([[F, H, G], State], Pf2, Pf3),
    insert([State, [F, H, G], Father, Dir], Pu2, Pu3)
.

% Pu et Pf sont vides, il n'y a plus d'état à explorer
aetoile(Pf, Pu, _) :-
    empty(Pu),
    empty(Pf),
    write('PAS de SOLUTION : L’ETAT FINAL N’EST PAS ATTEIGNABLE !\n'),
    !
.

% Le minimum de Pf est la solution (heuristique nulle), donc c'est terminé
aetoile(Pf, _, Qs) :-
    suppress_min([_, S], Pf, _),
    heuristique(S, 0),
    affiche_solution(S, Qs),
    !
.

% Exploration
aetoile(Pf1, Pu1, Qs1) :-
    suppress_min([[_, _, G], State], Pf1, Pf2),
    suppress([State, _, Father, Dir], Pu1, Pu2),
    %affiche_solution(State),
    insert([State, Father, Dir], Qs1, Qs2),

    expand(State, NextStates),
    Gn is G + 1,
    loop_successor(NextStates, Pf2, Pf3, Pu2, Pu3, Qs2, Gn, State),

    aetoile(Pf3, Pu3, Qs2)
.
