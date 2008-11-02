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

running_at(Job, Time) :-
	scheduled(Job, Start, Stop),
	Start =< Time,
	Stop > Time.

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

not_edf(Job, Violator, Violation) :-
	test_range(Job, Rel, Done),
	earlier_deadline(Job, Violator),
	(
	    (
		selected_in(Violator, Rel, Done, Violation),
		\+ running_at(Job, Violation)
	    );
	    (
		preempted_in(Job, Rel, Done, Violation),
		running_at(Violator, Violation)
	    )
	).


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