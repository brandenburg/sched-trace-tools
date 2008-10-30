#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>

#include "sched_trace.h"

static int map_file(const char* filename, void **addr, size_t *size)
{
	struct stat info;
	int error = 0;
	int fd;

	error = stat(filename, &info);
	if (!error) {
		*size = info.st_size;
		if (info.st_size > 0) {
			fd = open(filename, O_RDONLY);
			if (fd >= 0) {
				*addr = mmap(NULL, *size,
					     PROT_READ | PROT_WRITE,
					     MAP_PRIVATE, fd, 0);
				if (*addr == MAP_FAILED)
					error = -1;
				close(fd);
			} else
				error = fd;
		} else
			*addr = NULL;
	}
	return error;
}

static int map_trace(const char *name, void **start, void **end, size_t *size)
{
	int ret;

	ret = map_file(name, start, size);
	if (!ret)
		*end = *start + *size;
	return ret;
}


static void show(char* file)
{
	size_t s;
	struct st_event_record *rec, *end;
	if (map_trace(file, &rec, &end, &s) == 0) {
		print_all(rec, 
			  ((unsigned int)((char*) end - (char*) rec)) 
			  / sizeof(struct st_event_record));
	} else
		perror("mmap");
}


static struct heap* file2heap(char* file, unsigned int* count)
{
	size_t s;
	struct st_event_record *rec, *end;
	if (map_trace(file, &rec, &end, &s) == 0) {
		*count = ((unsigned int)((char*) end - (char*) rec))
			/ sizeof(struct st_event_record);
		return heapify_events(rec, *count);
	} else
		perror("mmap");
	return NULL;
}


/*
int main(int argc, char** argv)
{
	int i;
	for (i = 1; i < argc; i++)
		show(argv[i]);
	return 0;
}
*/

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
