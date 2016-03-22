#include <sys/socket.h>
#include <stddef.h>


int prod_send(int fd) {
    const void* buffer = NULL;
    const size_t length = 0;
    const int flags = 0;
    return send(fd, buffer, length, flags);
}


int prod_zero() {
    return zero_func();
}
