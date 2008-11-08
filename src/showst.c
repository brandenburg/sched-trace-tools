#include <stdio.h>
#include <stdlib.h>

#include "load.h"
#include "sched_trace.h"
#include "eheap.h"

int main(int argc, char** argv)
{
	unsigned int count;
	struct heap *h;
	struct heap_node *hn;
	u64 start_time = 0, time;

	h = load(argv + 1, argc - 1, &count);
	if (!h)
		return 1;
	printf("Loaded %u events.\n", count);
	while ((hn = heap_take(earlier_event, h))) {
		time =  event_time(heap_node_value(hn));
/*		if (!start_time && time)
			start_time = time;
		time -= start_time;
*/		time /= 1000000; /* convert to milliseconds */
		printf("[%10llu] ", time);
		print_event(heap_node_value(hn));
	}

	return 0;
}
