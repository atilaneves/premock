#include <sys/socket.h>
#include <stddef.h>


int func(int fd) {
    const void* buffer = NULL;
    const size_t length = 0;
    const int flags = 0;
    return send(fd, buffer, length, flags);
}
