#include "catch.hpp"
#include "premock.hpp"
#include <functional>

using namespace std;


static function<int(int)> mock_twice = [](int i) { return i * 2; };


TEST_CASE("REPLACE works correctly") {
    {
        REPLACE(twice, [](int i) { return i * 3; });
        REQUIRE(mock_twice(3) == 9);
    }
    REQUIRE(mock_twice(3) == 6);
}


TEST_CASE("MOCK returnValue") {
    {
        auto m = MOCK(twice);

        // since no return value is set, it returns the default int, 0
        REQUIRE(mock_twice(3) == 0);

        m.returnValue(42);
        REQUIRE(mock_twice(3) == 42);
    }
    REQUIRE(mock_twice(3) == 6);
}
