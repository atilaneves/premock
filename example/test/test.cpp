#include "mocks.hpp"
#include "prod.h"
#include <iostream>
#include <string>
#include <stdexcept>
#include <functional>


using namespace std;


template<typename A, typename E>
static void assertEqual(A&& actual, E&& expected) {
    if(actual != expected) throw runtime_error("\nExpected: " + to_string(expected) + "\n" + "Actual:   " + to_string(actual));
}

int main() {
    {
        auto _ = REPLACE(send, [](auto...) { return 7; });
        assertEqual(prod_send(0), 7);
    }
    {
        auto _ = REPLACE(zero_func, []() { return 3; });
        assertEqual(prod_zero(), 3);
    }
    {
        auto _ = REPLACE(one_func, [](int i) { return 4 * i; });
        assertEqual(prod_one(8), 36);
    }
    {
        auto _ = REPLACE(two_func, [](int i, int j) { return i + j + 1; });
        assertEqual(prod_two(3, 4), 8);
    }
    {
        auto _ = REPLACE(three_func, [](double, int j, const char*){ if(j == 2) throw runtime_error("oh noes"); });
        prod_three(0, 1, nullptr);
        try {
            prod_three(0, 0, nullptr); //should throw
            throw logic_error("oops"); //should never get here
        } catch(const runtime_error&) { }
    }

    {
        auto m = MOCK(two_func);
        m.returnValue(5); //prod_two should call mock_two_func and return 5 no matter what
        assertEqual(prod_two(99, 999), 5);
    }

    cout << "Ok" << endl;
}
