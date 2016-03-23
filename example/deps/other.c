#include "other.h"

int zero_func() {
    return 42;
}

int one_func(int i) {
    return i * 42;
}


int two_func(int i, int j) {
    return i * j;
}


void three_func(int i, int j, int k) {
    (void)i;
    (void)j;
    (void)k;
}
