/**
 This file is an example of production code to be tested,
 calling dependencies such as send or the included
 "other" module. 
 */

#include "other.h"
#include <sys/socket.h>
#include <stddef.h>


int prod_send(int fd) {
    const void* buffer = NULL;
    const size_t length = 0;
    const int flags = 0;
    return send(fd, buffer, length, flags);
}


int prod_zero() {
    return other_zero();
}

int prod_one(int i) {
    return other_one(i + 1);
}

int prod_two(int i, int j) {
    other_one(j + 2);
    return other_two(i - 1, j + 1);
}

void prod_three(double i, int j, const char* k) {
    other_three(i + 1, j + 2, k);
}
