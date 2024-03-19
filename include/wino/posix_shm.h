#ifndef _WINO_POSIX_SHM_H
#define _WINO_POSIX_SHM_H
#include <stdlib.h>

void randname(char *buf);
int create_shm_file(void);
int allocate_shm_file(size_t size);


#endif // _WINO_POSIX_SHM_H
