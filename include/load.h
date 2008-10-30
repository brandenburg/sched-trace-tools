#ifndef LOAD_H
#define LOAD_H

int map_trace(const char *name, void **start, void **end, size_t *size);
struct heap* load(char **files, int no_files, unsigned int *count);

#endif
