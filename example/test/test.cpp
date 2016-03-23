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
        REPLACE(send, [](auto...) { return 7; });
        assertEqual(prod_send(0), 7);
    }
    {
        REPLACE(zero_func, []() { return 3; });
        assertEqual(prod_zero(), 3);
    }
    {
        REPLACE(one_func, [](int i) { return 4 * i; });
        assertEqual(prod_one(8), 36);
    }
    {
        REPLACE(two_func, [](int i, int j) { return i + j + 1; });
        assertEqual(prod_two(3, 4), 8);
    }
    {
        REPLACE(three_func, [](double, int j, const char*){ if(j == 2) throw runtime_error("oh noes"); });
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
        m.expectCalled(1);
    }

    {
        auto m = MOCK(two_func);
        m.returnValues(11, 22, 33);
        assertEqual(prod_two(99, 999), 11);
        assertEqual(prod_two(99, 999), 22);
        assertEqual(prod_two(99, 999), 33);
        m.expectCalled(3);
    }


    cout << "Ok" << endl;
}