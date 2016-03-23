#include "mocks.hpp"
#include "prod.h"
#include <iostream>
#include <string>
#include <stdexcept>
#include <functional>


using namespace std;


template<typename A, typename E>
static void assertEqual(A&& actual, E&& expected) {
    if(actual != expected) throw runtime_error("Expected: " + to_string(expected) + "\n" + "Actual: " + to_string(actual));
}

int main() {
    {
        auto _ = MOCK(send, [](auto...) { return 7; });
        assertEqual(prod_send(0), 7);
    }
    {
        auto _ = MOCK(zero_func, []() { return 3; });
        assertEqual(prod_zero(), 3);
    }
    {
        auto _ = MOCK(one_func, [](int i) { return 4 * i; });
        assertEqual(prod_one(8), 36);
    }
    {
        auto _ = MOCK(two_func, [](int i, int j) { return i + j + 1; });
        assertEqual(prod_two(3, 4), 8);
    }

    cout << "Ok" << endl;
}
