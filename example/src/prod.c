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

int prod_one(int i) {
    return one_func(i + 1);
}

int prod_two(int i, int j) {
    return two_func(i - 1, j + 1);
}

void prod_three(int i, int j, int k) {
    three_func(i + 1, j + 2, k + 3);
}
