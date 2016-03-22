#include "MockScope.hpp"
#include "prod.hpp"
#include <iostream>
#include <string>
#include <stdexcept>
#include <functional>


using namespace std;

extern function<ssize_t(int, const void *, size_t, int)> mock_send;


int main() {
    auto mysend = mockScope(mock_send, [](auto...) { return 7; });
    const auto res = func(42);
    if(res != 7) throw runtime_error("Unexpected value: " + to_string(res));
    cout << "Result was " << res << endl;
}
