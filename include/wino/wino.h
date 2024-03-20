#ifndef _WINO_H
#define _WINO_H

#include "config.h"
#ifdef HAVE_UNISTD_H
#define _POSIX
#endif





#include <stdlib.h>

#ifdef _POSIX

// Posix Utils, TODO: Maybe move to a diffrent header for internals or platfrom specific stuff
int wino_create_shm_file(void);
int wino_allocate_shm_file(size_t size);

#endif // _POSIX


#endif // _WINO_H
