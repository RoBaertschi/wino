#ifndef _WINO_H
#define _WINO_H

#include "config.h"
#include "wayland-client-protocol.h"
#include "xdg-shell-client-protocol.h"
#ifdef HAVE_UNISTD_H
#define _POSIX
#endif

#include <stdlib.h>

/*##############################
||                            ||
||          Structs           ||
||                            ||
##############################*/


#define WINO_WINDOW_BACKENDS(_X) \
_X(0, "wayland", WAYLAND)

#define _WINDOW_BACKENDS_ENUM(id, str, name, ...) WINO_WINDOW_BACKEND_##name = id,

typedef enum wino_window_backend {
  WINO_WINDOW_BACKENDS( _WINDOW_BACKENDS_ENUM )
} wino_window_backend;

#undef _WINDOW_BACKENDS_ENUM

typedef struct wino_window {
  wino_window_backend backend;
  union {
    struct {
      struct wl_surface *wl_surface;
      struct xdg_surface *xdg_surface;
    } wayland;
  };
} wino_window;


/*##############################
||                            ||
||         functions          ||
||                            ||
##############################*/

/**
  * Turns the backend into a string
**/
char* wino_window_backend_to_string(wino_window_backend backend);


#ifdef _POSIX

// Posix Utils, TODO: Maybe move to a diffrent header for internals or platfrom specific stuff
int wino_create_shm_file(void);
int wino_allocate_shm_file(size_t size);

#endif // _POSIX


#endif // _WINO_H
