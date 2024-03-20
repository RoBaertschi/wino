#include <wino/wino.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <errno.h>
#include <time.h>
#include <unistd.h>

static void randname(char *buf) {
  struct timespec ts;
  clock_gettime(CLOCK_REALTIME, &ts);
  long r = ts.tv_nsec;
  for (int i = 0; i < 6; ++i) {
    buf[i] = 'A'+(r&15)+(r&16)*2;
    r >>= 5;
  }
}

int wino_create_shm_file() {
  int retries = 100;
  do {
    char name[] = "/wl_shm-XXXXXX";
    randname(name + sizeof(name) - 7);
    --retries;
    int fd = shm_open(name, O_RDWR | O_CREAT | O_EXCL, 0600);
    if (fd >= 0) {
      // After some reading the man pages, this will make sure, that
      // after all processes that opened the shm file have exisited, 
      // and then deallocates the shared memory.
      shm_unlink(name);
      return fd;
    }
  }while (retries > 0 && errno == EEXIST);
  return -1;
}

int wino_allocate_shm_file(size_t size) {
  int fd = wino_create_shm_file();
  if (fd < 0) {
    return -1;
  }
  int ret;
  do {
    ret = ftruncate(fd, size);
  }while (ret < 0 && errno == EINTR);

  if (ret < 0) {
    close(fd);
    return -1;
  }
  return fd;
}
