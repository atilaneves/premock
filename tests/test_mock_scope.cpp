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

        //calling it again should yield the same value
        REQUIRE(mock_twice(3) == 42);
    }
    REQUIRE(mock_twice(3) == 6);
}

static int function_that_calls_twice(int i) {
    return mock_twice(i + 1);
}

TEST_CASE("MOCK number of calls") {
    auto m = MOCK(twice);

    REQUIRE_THROWS(m.expectCalled()); //hasn't been called yet, so...

    function_that_calls_twice(2); //calls the mock_twice
    m.expectCalled().withValues(3);
    REQUIRE_THROWS(m.expectCalled()); //was called once, not twice

    for(int i = 0; i < 5; ++i) function_that_calls_twice(i);
    m.expectCalled(5);//.withValues({make_tuple(1), make_tuple(2), make_tuple(3), make_tuple(4), make_tuple(5)});
}
