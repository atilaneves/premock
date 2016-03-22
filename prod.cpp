#include <sys/socket.h>


int func(int fd) {
    const void* buffer{};
    const size_t length{};
    const int flags{};
    return send(fd, buffer, length, flags);
}
