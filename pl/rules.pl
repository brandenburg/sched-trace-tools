id(job(X, _Y), Z)    :- X = Z.
jobno(job(_X, Y), Z) :- Y = Z.

not_self(Job1, Job2) :-
	id(Job1, Id1),
	id(Job2, Id2),
	Id1 =\= Id2.

intersect(X1, Y1, X2, Y2) :-
	(X1 < X2 -> Y1 > X2 ; X1 < Y2).

parallel(Job1, Job2) :-
	scheduled(Job1, X1, Y1),
	scheduled(Job2, X2, Y2),
	not_self(Job1, Job2),
	intersect(X1, Y1, X2, Y2).

parallelism(Time, Par) :-
	(bagof(J, running_at(J, Time), Bag) -> length(Bag, Par) ; Par = 0).

parallelism_in(Start, End, Pars) :-
	setof((Time, P), X^Job^((scheduled(Job, X, Time) ; released(Job, Time)
	), Start =< Time, End > Time, parallelism(Time, P)), Pars).

running_at(Job, Time) :-
	scheduled(Job, Start, Stop),
	Start =< Time,
	Stop > Time.

last_scheduled(Job, A, B) :-
	setof((X, Y), scheduled(Job, X, Y), Bag),
	last(Bag, (A, B)).

selected_in(Job, Start, End, Point) :-
	scheduled(Job, X, _Y),
	in_range(Start, End, X),
	Point = X.

preempted_in(Job, Start, End, Point) :-
	scheduled(Job, _X, Y),
	in_range(Start, End, Y),
	Point = Y.

running_in(Job, Start, End) :-
	scheduled(Job, X, Y),
	intersect(X, Y, Start, End).

competing(Job1, Job2) :-
	released(Job1, Rel),
	completed(Job1, Done),
	running_in(Job2, Rel, Done),
	not_self(Job1, Job2).

pending_at(Job, Time) :-
	released(Job, Rel),
	Rel =< Time,
	(completed(Job, C) -> Time < C; true).

no_pending_at(Time, N) :-
	(bagof(J, pending_at(J, Time), Bag) -> length(Bag, N) ; N = 0).

no_pending_in(Start, End, Ns) :-
	setof((Time, P), X^Job^((scheduled(Job, X, Time) ; released(Job, Time)
	), Start =< Time, End > Time, no_pending_at(Time, P)), Ns).

earlier_deadline(Job1, Job2) :-
	deadline(Job1, Dl1),
	deadline(Job2, Dl2),
	Dl2 > Dl1.

test_range(Job, Start, End) :-
	released(Job, Start),
	deadline(Job, D),
	(completed(Job, C) -> End = C ; End = D).

in_range(Start, Stop, X) :-
	Start =< X,
	Stop > X.

tardy(Job) :-
	completed(Job, When),
	deadline(Job, ByWhen),
	ByWhen < When.

exec_time(Job, Alloc) :-
	bagof(Y - X, scheduled(Job, X, Y), Bag),
	sumlist(Bag, Alloc).

overrun(Job, Delta) :-
	id(Job, Task),
	wcet(Task, Wcet),
	exec_time(Job, ExecTime),
	Delta is ExecTime - Wcet,
	Delta > 0.

job_separation(Job, Sep) :-
	id(Job, T),
	jobno(Job, N),
	released(Job, Rel1),
	X is N - 1,
	released(job(T, X), Rel2),
	Sep is Rel1 - Rel2.

job_skew(Job, Skew) :-
	job_separation(Job, Sep),
	id(Job, T),
	period(T, Period),
	Skew is Sep - Period.

not_periodic(Job, Skew) :-
	job_skew(Job, Skew),
	Skew =\= 0.

not_sporadic(Job, Skew) :-
	job_skew(Job, Skew),
	Skew < 0.

not_work_conserving_on_at(Cpus, Time) :-
	parallelism(Time, P),
	P < Cpus,
	no_pending_at(Time, N),
	N > P.

not_work_conserving_on(Cpus, Job, Violation) :-
	(
	    scheduled(Job, _X, Violation) ;
	    released(Job, Violation)
	),
	not_work_conserving_on_at(Cpus, Violation).

not_work_conserving_on(Cpus, Violations) :-
	setof(T, Job^not_work_conserving_on(Cpus, Job, T), Violations).

not_edf(Job, Violator, Violation) :-
	test_range(Job, Rel, Done),
	(
	    (
		selected_in(Violator, Rel, Done, Violation),
		\+ running_at(Job, Violation)
	    );
	    (
		preempted_in(Job, Rel, Done, Violation),
		running_at(Violator, Violation)
	    )
	),
	earlier_deadline(Job, Violator).

edf_violations(Violations) :-
	bagof((Job, V, Vt), not_edf(Job, V, Vt), Violations).

show_job(Job) :-
	(completed(Job, C) -> X = C ; X = '[never]'),
	(deadline(Job, D)  -> Y = D ; Y = '[never]'),
	(released(Job, R)  -> Z = R ; Z = '[never]'),
	write(Job),
	write(' R='), write(Z),
	write(' D='), write(Y),
	write(' C='), write(X).

show_sched_at(Job, At) :-
	scheduled(Job, X, Y),
	X =< At, Y > At,
	write(' S=('), write(X), write(', '), write(Y), write(')').
show_sched_at(_, _) :-
	write(' S=[none]').

list_violations([]).
list_violations([(Job, V, Vt)|Rest]) :-
	completed(Job, _A),completed(V, _B),
	write(Vt), write(': '),
	nl, write('\t'), show_job(V), show_sched_at(V, Vt), write(' before '),
	nl, write('\t'), show_job(Job), show_sched_at(Job, Vt), nl,
	list_violations(Rest).
list_violations([(Job, _, _)|Rest]) :-
	write('skip '), write(Job), nl,
	list_violations(Rest).
list_edf_violations :-
	edf_violations(X), list_violations(X).

periodic :- \+ not_periodic(_Job, _Skew).
sporadic :- \+ not_sporadic(_Job, _Skew).
work_conserving_on(Cpus) :- \+ not_work_conserving_on(Cpus, _Job, __Vio).
edf :- \+ not_edf(_Job, _Vio, _VioT).