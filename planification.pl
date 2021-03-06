% Import du fichier dataset.pl
:- [datatest].

% ------------------
% Prédicats utiles :
% ------------------

% Somme les effectifs d'une liste de groupe :
sommeEffectif([], 0).
sommeEffectif(G, Somme) :- 
	taille(G, TailleGroupe),
	Somme is TailleGroupe.
sommeEffectif([G|Gs], Somme) :- 
	sommeEffectif(Gs, Reste),
	taille(G, TailleGroupe),
	Somme is TailleGroupe + Reste.

% Création des listes
makeSeances(ListeSeances):- findall(Seance, seance(Seance), ListeSeances).
% makeCreneaux(ListeCreneaux):- findall(Creneaux, creneau(Creneaux), ListeCreneaux).
% makeSalle(ListeSalles):- findall(Salle, salle(Salle), ListeSalles).

% -------------
% Contraintes :
% -------------

contrainteCM(S,C) :-
	\+typeSeance(S,cm); 
	(	
		estPlage(C,p2);
		estPlage(C,p3);
		estPlage(C,p5)
	).

contrainteUsage(S,R) :-
	\+typeSeance(S,projet);
	\+typeSeance(S,reunion);
	typeSeance(S,T),
	usageSalle(R,T).


% contrainteSalleLibre(C,R,[]).
contrainteSalleLibre(C,R,Solution) :-
	\+member([_,R,C],Solution).


%contrainteEnseignant(S,C,[]).
contrainteEnseignant(S,C,Solution) :-
	findall(Seance,member([Seance,_,C],Solution),ListeSeances),
	%member([Seance,_,C],Solution), % on regarde si on peut unifier une Seance avec la Solution
	findall(Enseignant,anime(S,Enseignant),ListeEnseignants),
	% anime(S,ListeEnseignants), % On prend le prof de S
	\+anime(ListeSeances,ListeEnseignants).
	%animePas(ListeSeances,Enseignant).
	% \+anime(Seance,Enseignant). % on regarde si c'est le même professeur

% contrainteEnseignant(S,C,[]).


contrainteTailleSalle(S, R) :- 
	taille(R, TailleSalle),
	findall(Groupe, assiste(Groupe, S), ListeGroupe),
	sommeEffectif(ListeGroupe, Total), 
	Total =< TailleSalle.

/* contrainteExisteDeja(Solution,SolutionExistantes) :-
	\+member(Solution,SolutionExistantes). */

/* contrainteIncompatibilite(S,C,Solution):-
	\+member([Sceance,_,C],Solution);
	findall(Groupe, assiste(S,Groupe),ListeGroupe),
	findall(Groupe2, assiste(Sceance,Groupe2),ListeGroupe2),
	forall(
		member(Groupebis,ListeGroupe),
			forall(
				member(Groupe2bis,ListeGroupe2),
					\+estIncompatible(Groupebis,Groupe2bis)),
		) */

contrainteIncompatibilite(S,C,Solution):-
	\+member([Seance,_,C],Solution);
	write("OUI LA VOIX"),
	findall(Seance,member([Seance,_,C],Solution),ListeSeances),
	findall(Groupe, assiste(Groupe,S),ListeGroupe),
	findall(Groupe2, assiste(Groupe2,ListeSeances),ListeGroupe2),
	\+groupesIncompatibles(ListeGroupe,ListeGroupe2).


% Ecrire Solution

ecrireSolution([]).
ecrireSolution(T):-

	seance(T),
	write("Seance : "),
	write(T),
	write("\n"),
	typeSeance(T,X),
	write("Type de la séance : "),
	write(X),
	write("\n"),
	findall(Groupe,assiste(Groupe,T),ListeGroupe),
	write("Groupes : "),
	write(ListeGroupe),
	write("\n"),
	findall(Enseignant,anime(T,Enseignant),ListeEnseignants),
	write("Enseignants : "),
	write(ListeEnseignants),
	write("\n");
	creneau(T),
	write("Creneau : "),
	write(T),
	write("\n");
	salle(T),
	write("Salle : "),
	write(T),
	write("\n"),
	write("--------------"),
	write("\n").
ecrireSolution([T|Q]):-
	ecrireSolution(T),
	ecrireSolution(Q).

ecrireSolution2(S):-
write(S).

% ------------------------------
% Algorithme de plannification :
% ------------------------------
planifier([],Solution):- ecrireSolution(Solution).
planifier(ListeSeances,Solution):-
	member(S, ListeSeances),
	salle(Room),
	creneau(C),

	% Contraintes : 
	%contrainteCM(S,C),
	%contrainteUsage(S,Room),
	%contrainteSalleLibre(C,Room,Solution),
	contrainteEnseignant(S,C,Solution),	
	%contrainteTailleSalle(S,R),
	% contrainteIncompatibilite(S,C,Solution),

	% contrainteExisteDeja(S,Solution),

	% Ajout de la plannification dans le résultat :
	/* ecrireSolution2(Solution),
	write("\n"), */
	append([[S, Room, C]], Solution, Result),
	delete(ListeSeances	, S, ListeTronquee),
	planifier(ListeTronquee, Result).

% --------------------------------------------------

faire_planification(Solution):-
	makeSeances(ListeSeances),
	planifier(ListeSeances,Solution).

faire_planification():-
	faire_planification([]).