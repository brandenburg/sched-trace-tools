#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>

#include "load.h"
#include "sched_trace.h"
#include "eheap.h"

static void usage(const char *str)
{
	fprintf(stderr,
		"\n  USAGE\n"
		"\n"
		"    st_show [opts] <file.st>+\n"
		"\n"
		"  OPTIONS\n"
		"     -r         -- find task system release and exit\n"
		"\n\n"
		);
	fprintf(stderr, "Aborted: %s\n", str);
	exit(1);
}

#define OPTSTR "r"

int main(int argc, char** argv)
{
	unsigned int count;
	struct heap *h;
	struct heap_node *hn;
	u64 time;
	struct st_event_record *rec;
	int find_release = 0;
	int opt;

	while ((opt = getopt(argc, argv, OPTSTR)) != -1) {
		switch (opt) {
		case 'r':
			find_release = 1;
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
		return 1;
	if (!find_release)
		printf("Loaded %u events.\n", count);
	while ((hn = heap_take(earlier_event, h))) {
		time =  event_time(heap_node_value(hn));
		time /= 1000000; /* convert to milliseconds */
		if (!find_release) {
			printf("[%10llu] ", (unsigned long long) time);
			print_event(heap_node_value(hn));
		} else {
			rec = heap_node_value(hn);
			if (rec->hdr.type == ST_SYS_RELEASE) {
				printf("%6.2fms\n", rec->data.raw[1] / 1000000.0);
				break;
			}
		}
	}

	return 0;
}
