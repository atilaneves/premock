#include "mocks.hpp"
#include "prod.h"
#include "cpp_prod.hpp"
#include <iostream>
#include <string>
#include <stdexcept>
#include <functional>


using namespace std;


template<typename A, typename E>
static void assertEqual(A&& actual, E&& expected) {
    if(actual != expected)
        throw runtime_error("\nExpected: " + to_string(expected) +
                            "\nActual:   " + to_string(actual));
}

int main() {
    {
        REPLACE(send, [](auto...) { return 7; });
        assertEqual(prod_send(0), 7);
    }

    // out of scope, send reverts to the "real" implementation
    // which will return -1 since 0 isn't a valid socket file
    // descriptor
    assertEqual(prod_send(0), -1);

    {
        auto m = MOCK(send);
        prod_send(3);
        m.expectCalled().withValues(3, nullptr, 0, 0);
    }
    {
        REPLACE(other_zero, []() { return 3; });
        assertEqual(prod_zero(), 3);
    }
    {
        REPLACE(other_one, [](int i) { return 4 * i; });
        assertEqual(prod_one(8), 36);
    }
    {
        REPLACE(other_two, [](int i, int j) { return i + j + 1; });
        assertEqual(prod_two(3, 4), 8);
    }
    {
        REPLACE(other_three, [](double, int j, const char*){
            if(j == 2) throw runtime_error("oh noes");
        });
        prod_three(0, 1, nullptr);
        try {
            prod_three(0, 0, nullptr); //should throw
            throw logic_error("oops"); //should never get here
        } catch(const runtime_error&) { }
    }

    {
        auto m = MOCK(other_two);
        m.returnValue(5); //prod_two should call mock_other_two and return 5 no matter what
        assertEqual(prod_two(99, 999), 5);
        m.expectCalled().withValues(98, 1000);
    }

    {
        auto m = MOCK(other_two);
        m.returnValue(11, 22, 33);
        assertEqual(prod_two(99, 999), 11);
        assertEqual(prod_two(9, 10), 22);
        assertEqual(prod_two(5, 5), 33);
        m.expectCalled(3).withValues(4, 6);
    }

    {
        auto mock1 = MOCK(other_one); //because we can
        auto mock2 = MOCK(other_two);
        mock2.returnValue(11, 22, 33);
        assertEqual(prod_two(99, 999), 11);
        assertEqual(prod_two(9, 10), 22);
        assertEqual(prod_two(5, 5), 33);
        mock2.expectCalled(3).withValues({make_tuple(98, 1000), make_tuple(8, 11), make_tuple(4, 6)});
    }

    {
        //C++ function mocking
        auto m = MOCK(twice);
        prod_twice(2, 3);
        m.expectCalled().withValues(5);
    }

    {
        REPLACE(other_two, [](auto...) { return 0; });
        REPLACE(other_three, [](auto...) { return 0; });
    }


    cout << "Ok C++ Example" << endl;
}
