#include "mock.hpp"
#include "prod.h"
#include <iostream>
#include <string>
#include <stdexcept>
#include <functional>


using namespace std;


int main() {
    auto mysend = mockScope(mock_send, [](auto...) { return 7; });
    const auto res = func(42);
    if(res != 7) throw runtime_error("Unexpected value: " + to_string(res));
    cout << "Result was " << res << endl;
}
