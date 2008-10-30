#include <stdio.h>
#include <stdlib.h>

#include "load.h"
#include "sched_trace.h"
#include "eheap.h"

static struct heap* file2heap(char* file, unsigned int* count)
{
	size_t s;
	struct st_event_record *rec, *end;
	if (map_trace(file, (void**) &rec, (void**) &end, &s) == 0) {
		*count = ((unsigned int)((char*) end - (char*) rec))
			/ sizeof(struct st_event_record);
		return heapify_events(rec, *count);
	} else
		perror("mmap");
	return NULL;
}

int main(int argc, char** argv)
{
	int i;
	unsigned int count;
	struct heap h, *h2;
	struct heap_node *hn;
	u64 start_time = 0, time;

	heap_init(&h);

	for (i = 1; i < argc; i++) {
		printf("Heapify %s ", argv[i]);
		h2 = file2heap(argv[i], &count);
		if (h2) {
			printf("merging ");
			heap_union(earlier_event, &h, h2);
			printf("done [%u events].\n", count);
		} else
			printf("failed.\n");
	}

	while ((hn = heap_take(earlier_event, &h))) {
		time =  event_time(heap_node_value(hn));
		if (!start_time && time)
			start_time = time;
		time -= start_time;
		time /= 1000000; /* convert to milliseconds */
		printf("[%10llu] ", time);
		print_event(heap_node_value(hn));
	}

	return 0;
}
