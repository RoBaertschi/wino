#ifdef WINO_LINUX

typedef struct wl_state {
  struct wl_display *wl_display;
  struct wl_registry *wl_registry;
  struct wl_shm *wl_shm;
  struct wl_compositor *compositor;
  struct xdg_wm_base *xdg_wm_base;
} wl_state;

#endif
