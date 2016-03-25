/**
 This file includes example functions the production code
 depends on and calls
 */

#include "other.h"

int other_zero() {
    return 42;
}

int other_one(int i) {
    return i * 42;
}


int other_two(int i, int j) {
    return i * j;
}


void other_three(double i, int j, const char* k) {
    (void)i;
    (void)j;
    (void)k;
}
