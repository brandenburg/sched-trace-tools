#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>

#include <stdio.h>

#include "sched_trace.h"
#include "eheap.h"

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

int map_trace(const char *name, void **start, void **end, size_t *size)
{
	int ret;

	ret = map_file(name, start, size);
	if (!ret)
		*end = *start + *size;
	return ret;
}


static struct heap* heap_from_file(char* file, unsigned int* count)
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

struct heap* load(char **files, int no_files, unsigned int *count)
{
	int i;
	unsigned int c;
	struct heap *h = NULL, *h2;
	*count = 0;
	for (i = 0; i < no_files; i++) {
		h2 = heap_from_file(files[i], &c);
		if (!h2)
			/* potential memory leak, don't care */
			return NULL;
		if (h)
			heap_union(earlier_event, h, h2);
		else
			h = h2;
		*count += c;
	}
	return h;
}
