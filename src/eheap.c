#include <stdlib.h>

#include "sched_trace.h"
#include "eheap.h"

int earlier_event(struct heap_node* _a, struct heap_node* _b)
{
	struct st_event_record *a, *b;
	a = heap_node_value(_a);
	b = heap_node_value(_b);
	return event_time(a) < event_time(b);
}


struct heap* heapify_events(struct st_event_record *ev, unsigned int count)
{
	struct heap_node* hn;
	struct heap* h;
	h  = malloc(sizeof(struct heap));
	hn = malloc(sizeof(struct heap_node) * count);
	if (!hn || !h)
		return NULL;
	heap_init(h);
	while (count) {
		heap_node_init(hn, ev);
		heap_insert(earlier_event, h, hn);
		hn++;
		ev++;
		count--;
	}
	return h;
}


