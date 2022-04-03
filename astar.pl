%*******************************************************************************
%                                    AETOILE
%*******************************************************************************

/*
Rappels sur l'algorithme
 
- structures de donnees principales = 2 ensembles : P (etat pendants) et Q (etats clos)
- P est dedouble en 2 arbres binaires de recherche equilibres (AVL) : Pf et Pu
 
   Pf est l'ensemble des etats pendants (pending states), ordonnes selon
   f croissante (h croissante en cas d'egalite de f). Il permet de trouver
   rapidement le prochain etat a developper (celui qui a f(U) minimum).
   
   Pu est le meme ensemble mais ordonne lexicographiquement (selon la donnee de
   l'etat). Il permet de retrouver facilement n'importe quel etat pendant

   On gere les 2 ensembles de façon synchronisee : chaque fois qu'on modifie
   (ajout ou retrait d'un etat dans Pf) on fait la meme chose dans Pu.

   Q est l'ensemble des etats deja developpes. Comme Pu, il permet de retrouver
   facilement un etat par la donnee de sa situation.
   Q est modelise par un seul arbre binaire de recherche equilibre.

Predicat principal de l'algorithme :

   aetoile(Pf,Pu,Q)

   - reussit si Pf est vide ou bien contient un etat minimum terminal
   - sinon on prend un etat minimum U, on genere chaque successeur S et les valeurs g(S) et h(S)
	 et pour chacun
		si S appartient a Q, on l'oublie
		si S appartient a Ps (etat deja rencontre), on compare
			g(S)+h(S) avec la valeur deja calculee pour f(S)
			si g(S)+h(S) < f(S) on reclasse S dans Pf avec les nouvelles valeurs
				g et f 
			sinon on ne touche pas a Pf
		si S est entierement nouveau on l'insere dans Pf et dans Ps
	- appelle recursivement etoile avec les nouvelles valeurs NewPF, NewPs, NewQs

*/

%*******************************************************************************

:- ['avl.pl'].       % predicats pour gerer des arbres bin. de recherche   
:- ['taquin.pl'].    % predicats definissant le systeme a etudier

%*******************************************************************************

avl_pf(State, Pf) :-
	heuristique(State, H),
	empty(Empty),
	insert([[H, 0, H], State], Empty, Pf).

avl_pu(State, Pu) :-
	heuristique(State, H),
	empty(Empty),
	insert([State, [H, 0, H], nil, nil], Empty, Pu).

main :-
	% initialisations Pf, Pu et Q 
	initial_state(S0),
	avl_pf(S0, Pf),
	avl_pu(S0, Pu),
	empty(Q),
	aetoile(Pf, Pu, Q).


%*******************************************************************************
afficher_solution(S) :- final_state(S). /*A FAIRE*/

expand(State, [_, _, G], Successors) :- 
	findall(
		[Next, [Fs, Hs, Gs], State, Rule],
		(
			rule(Rule, _, State, Next),
			heuristique(Next,Hs),
			Gs is G + 1,
			Fs is Hs + Gs
		),
		Successors).

loop_successors([], _, _, _, _, _).
loop_successors([Node | NextNodes], Pf1, Pf3, Pu1, Pu3, Q) :-
	treat_one_successor(Node, Pf1, Pf2, Pu1, Pu2, Q),
	loop_successors(NextNodes, Pf2, Pf3, Pu2, Pu3, Q).

% Successeur déjà présent dans Q, rien à faire, 
% on a déjà le meilleur résultat possible
treat_one_successor([State, _, _, _], Pf, Pf, Pu, Pu, Q) :-
	belongs([State, _, _, _], Q).

% Successur présent dans Pu, donc déjà exploré, avec un
% meilleur score
treat_one_successor([State, [F, H, G], Father, Rule], Pf1, Pf3, Pu1, Pu3, _) :-
	belongs([State, [_, _, G_old], _, _], Pu1),
	G < G_old,
	suppress([State, _, _, _], Pu1, Pu2),
	suppress([_, State], Pf1, Pf2),
	insert([State, [F, H, G], Father, Rule], Pu2, Pu3),
	insert([[F, H, G], State], Pf2, Pf3).

% Successur présent dans Pu, donc déjà exploré, avec un
% moins bon score
treat_one_successor([State, [_, _, G], _, _], Pf1, Pf2, Pu1, Pu2, _) :-
	belongs([State, [_, _, G_old], _, _], Pu1),
	G >= G_old,
	Pf2 = Pf1,
	Pu2 = Pu1.

% Successeur nouveau
treat_one_successor([State, [F, H, G], Father, Rule], Pf1, Pf2, Pu1, Pu2, _) :-
	insert([State, [F,H,G], Father, Rule], Pu1, Pu2),
	insert([[F,H,G], State], Pf1, Pf2).

aetoile(Pf, Pu, _ ) :-
	empty(Pf),
	empty(Pu),
	writeln('PAS DE SOLUTION : L’ÉTAT FINAL N’EST PAS ATTEIGNABLE !'),
	!.

aetoile(Pf, _, Q) :-
	suppress_min([_, S], Pf, _),
	heuristique(S, 0),
	afficher_solution(S),
	!.

aetoile(Pf, Pu, Q) :-
	suppress_min([[F, H, G], State], Pf, Pf2),
	suppress([State, [F, H, G], Father, Rule], Pu, Pu2),
	expand(State, [F, H, G], Successors),
	loop_successors(Successors, Pf2, Pf3, Pu2, Pu3, Q),
	insert([State, [F, H, G], Father, Rule], Q, Q2),
	aetoile(Pf3, Pu3, Q2).

%**********************
%   TEST EXPAND : OK
%**********************

test_expand :-
	initial_state(S0),
	test_expand_detail(S0),
	test_expand_detail([[b, h, c], [a, vide, d], [g, f, e]]),
	test_expand_detail([[g, d, vide], [a, c, h], [b, f, e]]).

test_expand_detail(State) :-
	heuristique(State,H),
	G is 0,
	F is G + H,
	writeln('Etat étudié :'),
	writeln(State),
	writeln('Etats suivants:'),
	expand(State, [F,H,G], NextNodes),
	affiche_liste(NextNodes),
	writeln('').

affiche_liste([]).
affiche_liste([Elem|Rest]) :- 	writeln(Elem), affiche_liste(Rest).
