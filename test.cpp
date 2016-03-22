#include "mocks.hpp"
#include "prod.h"
#include <iostream>
#include <string>
#include <stdexcept>
#include <functional>


using namespace std;


int main() {
    {
        auto _ = MOCK(send, [](auto...) { return 7; });
        const auto res = prod_send(42);
        if(res != 7) throw runtime_error("Unexpected send value: " + to_string(res));
    }
    {
        auto _ = MOCK(zero_func, []() { return 3; });
        const auto res = prod_zero();
        if(res != 3) throw runtime_error("Unexpected zero value: " + to_string(res));
    }
    {
        auto _ = MOCK(one_func, [](int i) { return 4 * i; });
        const auto res = prod_one(8);
        if(res != 36) throw runtime_error("Unexpected one value: " + to_string(res));
    }
    {
        auto _ = MOCK(two_func, [](int i, int j) { return i + j + 1; });
        const auto res = prod_two(3, 4);
        if(res != 8) throw runtime_error("Unexpected two value: " + to_string(res));
    }

}
