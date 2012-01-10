#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <limits.h>
#include <float.h>
#include <string.h>

#include "sched_trace.h"
#include "eheap.h"
#include "load.h"


static void write_prolog_kb(void)
{
	struct task *t;
	struct evlink *e, *e2;

	for_each_task(t)
		printf("period(%d, %f).\n", t->pid, ns2ms(per(t)));

	for_each_task(t)
		printf("wcet(%d, %f).\n", t->pid, ns2ms(exe(t)));

	for_each_task(t) {
		for_each_event_t(t, e, ST_RELEASE)
			printf("released(job(%u, %u), %f).\n",
			       e->rec->hdr.pid,
			       e->rec->hdr.job,
			       ns2ms_adj(e->rec->data.release.release));
	}

	for_each_task(t) {
		for_each_event_t(t, e, ST_RELEASE)
			printf("deadline(job(%u, %u), %f).\n",
			       e->rec->hdr.pid,
			       e->rec->hdr.job,
			       ns2ms_adj(e->rec->data.release.deadline));
	}

	for_each_task(t) {
		for_each_event_t(t, e, ST_COMPLETION)
			printf("completed(job(%u, %u), %f).\n",
			       e->rec->hdr.pid,
			       e->rec->hdr.job,
			       ns2ms_adj(e->rec->data.completion.when));
	}

	for_each_task(t) {
		e = t->events;
		while (e) {
			find(e, ST_SWITCH_TO);
			e2 = e;
			find(e, ST_SWITCH_AWAY);
			printf("scheduled(job(%u, %u), %f, %f).\n",
			       e2->rec->hdr.pid,
			       e2->rec->hdr.job,
			       ns2ms_adj(e2->rec->data.switch_to.when),
			       ns2ms_adj(e->rec->data.switch_away.when));
		}
	}

	for_each_task(t) {
		e = t->events;
		while (e) {
			find(e, ST_BLOCK);
			e2 = e;
			find(e, ST_RESUME);
			printf("suspended(job(%u, %u), %f, %f).\n",
			       e2->rec->hdr.pid,
			       e2->rec->hdr.job,
			       ns2ms_adj(e2->rec->data.block.when),
			       ns2ms_adj(e->rec->data.resume.when));
		}
	}
}

int intersect(double *x, double *y, double from, double to)
{
	if (*x < from ? *y > from : *x < to) {
		*x = *x < from ? from : *x;
		*y = *y > to   ? to   : *y;
		return 1;
	} else
		return 0;
}

int in_range(double from, double x, double to)
{
	return from <= x && x <= to;
}

static void write_asy(double from, double to)
{
	struct task *t;
	struct evlink *e, *e2;
	double t1, t2;
	u32 n = count_tasks();

	printf("import sched;\n");
	printf("prepare_schedule(%f, %f, %d);\n", from, to, n);
	printf("draw_grid();\n");

	for_each_task(t) {
		printf("task(%u, %u, %f, %f);\n",
		       idx(t), t->pid, ns2ms(exe(t)), ns2ms(per(t)));
	}

	for_each_task(t) {
		e = t->events;
		while (e) {
			find(e, ST_SWITCH_TO);
			e2 = e;
			find(e, ST_SWITCH_AWAY);
			t1 = ns2ms_adj(e2->rec->data.switch_to.when);
			t2 = ns2ms_adj(e->rec->data.switch_away.when);
			if (intersect(&t1, &t2, from, to))
				printf("scheduled(%u, %u, (%f, %f));\n",
				       idx(t), e->rec->hdr.cpu, t1, t2);
		}
	}

	for_each_task(t) {
		for_each_event_t(t, e, ST_RELEASE) {
			t1 = ns2ms_adj(e->rec->data.release.release);
			t2 = ns2ms_adj(e->rec->data.release.deadline);
			if (in_range(from, t1, to))
				printf("release(%u, %u, %f);\n", idx(t), e->rec->hdr.job, t1);
			if (in_range(from, t2, to))
				printf("deadline(%u, %u, %f);\n", idx(t), e->rec->hdr.job, t2);
		}
	}

	for_each_task(t) {
		for_each_event_t(t, e, ST_COMPLETION) {
			t1 = ns2ms_adj(e->rec->data.completion.when);
			if (in_range(from, t1, to))
				printf("completed(%u, %u, %f);\n", idx(t), e->rec->hdr.job, t1);
		}
	}

	for_each_task(t) {
		for_each_event_t(t, e, ST_BLOCK) {
			t1 = ns2ms_adj(e->rec->data.block.when);
			if (in_range(from, t1, to))
				printf("blocked(%u, %f);\n", idx(t), t1);
		}
	}

	for_each_task(t) {
		for_each_event_t(t, e, ST_RESUME) {
			t1 = ns2ms_adj(e->rec->data.resume.when);
			if (in_range(from, t1, to))
				printf("resumed(%u, %f);\n", idx(t), t1);
		}
	}

//	printf("yaxis();\n");
//	printf("xaxis(\"time (ms)\", BottomTop);\n");
}


static void usage(const char *str)
{
	fprintf(stderr,
		"\n  USAGE\n"
		"\n"
		"    st2pl [opts] <file.st>+\n"
		"\n"
		"  OPTIONS\n"
		"     -f <time in ms>  -- minimum event time (use to limit output)\n"
		"     -t <time in ms>  -- maximum event time\n"
		"     -l <lang>        -- target language (pl, asy)\n"
		"\n\n"
		);
	fprintf(stderr, "Aborted: %s\n", str);
	exit(1);
}

typedef enum {
	UNKNOWN,
	PROLOG,
	ASYMPTOTE,
} lang_t;

#define streq(a, b) (0 == strcmp(a, b))

static lang_t str2mode(const char* str)
{
	if (streq(str, "pl"))
		return PROLOG;
	else if (streq(str, "asy"))
		return ASYMPTOTE;
	return UNKNOWN;
}


#define OPTSTR "f:t:l:m:M:"

int main(int argc, char** argv)
{
	int i;
	unsigned int count;
	int opt;
	double from = 0.0;
	double to   = DBL_MAX;
	lang_t mode = PROLOG;
	struct heap *h;

	for (i = 0; i < MAX_TASKS; i++) {
		tasks[i] = (struct task) {0, 0, NULL, NULL, NULL, NULL};
		tasks[i].next = &tasks[i].events;
	}

	while ((opt = getopt(argc, argv, OPTSTR)) != -1) {
		switch (opt) {
		case 'l':
			mode = str2mode(optarg);
			if (!mode)
				usage("Unsupported target language.");
			break;
		case 'f':
			from = atof(optarg);
			break;
		case 't':
			to = atof(optarg);
			break;
		case 'm':
			g_min_task = atoi(optarg);
			if (g_min_task > g_max_task) {
				usage("-m cannot exceed -M.");
			}
			break;
		case 'M':
			g_max_task = atoi(optarg);
			if (g_min_task > g_max_task) {
				usage("-m cannot exceed -M.");
			}
			if (g_max_task > MAX_TASKS) {
				g_max_task = MAX_TASKS;
			}
			break;
		case 'h':
			usage("Help requested.");
			break;
		case ':':
			usage("Argument missing.");
			break;
		case '?':
		default:
			usage("Bad argument.");
			break;
		}
	}


	h = load(argv + optind, argc - optind, &count);
	if (!h)
		usage("Loading traces failed.");
	fprintf(stderr, "Loaded %u events.\n", count);
	split(h, count, 0);
	switch (mode) {
	case PROLOG:
		crop_events_all(from, to);
		write_prolog_kb();
		break;
	case ASYMPTOTE:
		write_asy(from, to);
		break;
	default:
		usage("WTF?");
		break;
	}
	return 0;
}
