#include <assert.h>
#include <stdbool.h>
#include <wino/wino.h>

#define PRINT_WINDOW_BACKEND(id, str, name, ...) case WINO_WINDOW_BACKEND_##name: return str;

char* wino_window_backend_to_string(wino_window_backend backend) {
  switch (backend) {
    WINO_WINDOW_BACKENDS(PRINT_WINDOW_BACKEND)
    default: assert(false && "non exsistant backend for to string function");
  }
}
