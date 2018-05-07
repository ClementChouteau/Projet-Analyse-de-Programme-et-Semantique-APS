% Règles de typages applicables sur un programme APS2 transformé en terme prolog

% contient(contexte, var, type)
contient([(X1, T1)|_], X1, T1).
contient([(_, _)|G2], X2, T2) :- contient(G2, X2, T2).

listeTypesArgs([], []).
listeTypesArgs([(_, T1)|AnTn], [T1|TnListe]) :- listeTypesArgs(AnTn, TnListe).

listeTypes(_, [], []).
listeTypes(G, [E1|Er], [T1|Tr]) :- expr(G, E1, T1), listeTypes(G, Er, Tr).

% expr(contexte, expression, type)
expr(_, N, int) :- integer(N).
expr(G, ident(X), T) :- contient(G, X, T).
expr(_, true, bool).
expr(_, false, bool).

expr(G, not(E1), bool) :- expr(G, E1, bool).
expr(G, and(E1, E2), bool) :- expr(G, E1, bool), expr(G, E2, bool).
expr(G, or(E1, E2), bool) :- expr(G, E1, bool), expr(G, E2, bool).

expr(G, eq(E1, E2), bool) :- expr(G, E1, int), expr(G, E2, int).
expr(G, lt(E1, E2), bool) :- expr(G, E1, int), expr(G, E2, int).

expr(G, add(E1, E2), int) :- expr(G, E1, int), expr(G, E2, int).
expr(G, sub(E1, E2), int) :- expr(G, E1, int), expr(G, E2, int).
expr(G, mul(E1, E2), int) :- expr(G, E1, int), expr(G, E2, int).
expr(G, div(E1, E2), int) :- expr(G, E1, int), expr(G, E2, int).

expr(G, alloc(E), vec(_)) :- expr(G, E, int).

expr(G, nth(E1, E2), T) :- expr(G, E1, vec(T)), expr(G, E2, int).

expr(G, len(E), int) :- expr(G, E, vec(_)).

expr(G, abst(XsTs, E
), fleche(Ts, Tr)) :-
	listeTypesArgs(XsTs, Ts),
	append(XsTs, G, XsTsG),
	expr(XsTsG, E, Tr).

expr(G, app(F, Es), Tr) :-
	listeTypes(G, Es, Ts),
	expr(G, F, fleche(Ts, Tr)).

expr(G, if(E1, E2, E3), T) :-
	expr(G, E1, bool), expr(G, E2, T), expr(G, E3, T).

% dec (contexte, declaration, contexte')
dec(G, const(X, T, E), [(X, T)|G]) :- expr(G, E, T).
dec(G, var(X, T), [(X, T)|G]).

dec(G, fun(X, Tr, XsTs, E), [(X, fleche(Ts, Tr))|G]) :-
	listeTypesArgs(XsTs, Ts),
	append(XsTs, G, XsTsG),
	expr(XsTsG, E, Tr).

dec(G, fun_rec(X, Tr, XsTs, E), [(X, fleche(Ts, Tr))|G]) :-
	listeTypesArgs(XsTs, Ts),
	append(XsTs, G, XsTsG),
	expr([(X, fleche(Ts, Tr))|XsTsG], E, Tr).

dec(G, proc(X, XsTs, prog(CS)), [(X, fleche(Ts, void))|G]) :-
	listeTypesArgs(XsTs, Ts),
	append(XsTs, G, XsTsG),
	cmds(XsTsG, CS, void).

dec(G, proc_rec(X, XsTs, prog(CS)), [(X, fleche(Ts, void))|G]) :-
	listeTypesArgs(XsTs, Ts),
	append(XsTs, G, XsTsG),
	cmds([(X, fleche(Ts, void))|XsTsG], CS, void).

% stat (contexte, echo, void)
stat(G, echo(E), void) :- expr(G, E, int).
stat(G, set(X, E), void) :- contient(G, X, T), expr(G, E, T).
stat(G, set(E1, E2), void) :- expr(G, E1, T), expr(G, E2, T).

stat(G, if_imp(E, prog(CS1), prog(CS2)), void) :-
	expr(G, E, bool), cmds(G, CS1, void), cmds(G, CS2, void).

stat(G, while(E, prog(CS)), void) :- expr(G, E, bool), cmds(G, CS, void).

stat(G, call(X, Es), void) :-
	listeTypes(G, Es, Ts),
	contient(G, X, fleche(Ts, void)).

% cmds (contexte, commandes, void)
cmds(G, [Dec|CS], void) :- dec(G, Dec, G2), cmds(G2, CS, void).
cmds(G, [Stat|CS], void) :- stat(G, Stat, void), cmds(G, CS, void).
cmds(_, [], void).

% prog (programme, void)
prog(prog(CS), void) :- cmds([], CS, void).

main_stdin :-
	read(user_input, T),
	prog(T, R),
	print(R).
