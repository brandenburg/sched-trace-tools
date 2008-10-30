#include <stdio.h>
#include <stdlib.h>

#include "load.h"
#include "sched_trace.h"
#include "eheap.h"

#define MAX_TASKS 100

struct evlink {
	struct evlink *next;
	struct st_event_record* rec;
};

struct task {
	int pid;
	unsigned int no_events;
	struct st_event_record* name;
	struct st_event_record* param;
	struct evlink* events;
	struct evlink** next;
};

static struct task tasks[MAX_TASKS];

static struct task* by_pid(int pid)
{
	int i = 0;
	/* slow, don't care for now */
	for (i = 0; i < MAX_TASKS; i++) {
		if (!tasks[i].pid) /* end, allocate */
			tasks[i].pid = pid;
		if (tasks[i].pid == pid)
			return tasks + i;
	}
	return NULL;
}

static void split(struct heap* h, unsigned int count)
{
	struct evlink *lnk = malloc(count * sizeof(struct evlink));
	struct heap_node *hn;
	u64 start_time = 0, time;
	struct st_event_record *rec;
	struct task* t;

	if (!lnk) {
		perror("malloc");
		return;
	}

	while ((hn = heap_take(earlier_event, h))) {
		rec = heap_node_value(hn);
		time =  event_time(rec);
		if (!start_time && time)
			start_time = time;
		t = by_pid(rec->hdr.pid);
		if (!t) {
			printf("dropped %d\n", rec->hdr.pid);
			continue;
		}
		switch (rec->hdr.type) {
		case ST_PARAM:
			t->param = rec;
			break;
		case ST_NAME:
			t->name = rec;
			break;
		default:
			lnk->rec = rec;
			lnk->next = NULL;
			*(t->next) = lnk;
			t->next = &lnk->next;
			lnk++;
			t->no_events++;
			break;
		}
	}
}

static const char* tsk_name(struct task* t)
{
	if (t->name)
		return t->name->data.name.cmd;
	else
		return "<unknown>";
}

static u32 per(struct task* t)
{
	if (t->param)
		return t->param->data.param.period;
	else
		return 0;
}

static u32 exe(struct task* t)
{
	if (t->param)
		return t->param->data.param.wcet;
	else
		return 0;
}


static void show_tasks(void)
{
	int i;
	for (i = 0; i < MAX_TASKS; i++)
		if (tasks[i].pid) {
			printf("%5d:%20s (%10u,%10u) [%6u events]\n", tasks[i].pid, 
			       tsk_name(tasks + i),
			       exe(tasks + i),
			       per(tasks + i),
			       tasks[i].no_events);
		}
}

int main(int argc, char** argv)
{
	int i;
	unsigned int count;
	struct heap *h;

	for (i = 0; i < MAX_TASKS; i++) {
		tasks[i] = (struct task) {0, 0, NULL, NULL, NULL, NULL};
		tasks[i].next = &tasks[i].events;
	}

	h = load(argv + 1, argc - 1, &count);
	if (!h)
		return 1;
	printf("Loaded %u events.\n", count);
	split(h, count);
	show_tasks();
	return 0;
}
