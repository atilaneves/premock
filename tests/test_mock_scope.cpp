#include "catch.hpp"
#include "premock.hpp"
#include <functional>
#include <string>

using namespace std;


static function<int(int)> mock_twice = [](int i) { return i * 2; };


TEST_CASE("REPLACE works correctly") {
    {
        REPLACE(twice, [](int i) { return i * 3; });
        REQUIRE(mock_twice(3) == 9);
    }
    REQUIRE(mock_twice(3) == 6); //should return to default implementation
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

        m.returnValue(7, 42, 99);
        REQUIRE(mock_twice(3) == 7);
        REQUIRE(mock_twice(3) == 42);
        REQUIRE(mock_twice(3) == 99);
    }
    REQUIRE(mock_twice(3) == 6); //should return to default implementation
}

static int twiceClient(int i) {
    return mock_twice(i + 1);
}

TEST_CASE("MOCK expect calls to twice") {
    auto m = MOCK(twice);

    REQUIRE_THROWS(m.expectCalled()); //hasn't been called yet, so...

    twiceClient(2); //calls mock_twice internally
    m.expectCalled().withValues(3);
    REQUIRE_THROWS(m.expectCalled()); //was called once, not twice

    for(int i = 0; i < 5; ++i) twiceClient(i);
    m.expectCalled(5).withValues({make_tuple(1), make_tuple(2), make_tuple(3), make_tuple(4), make_tuple(5)});
}


static function<int(int, string)> mock_binary = [](int i, string s) { return i + s.size(); };
static int binaryClient(int i, string s) {
    return mock_binary(i + 2, s + "_foo");
}

TEST_CASE("Mock expect calls to binary") {
    auto m = MOCK(binary);

    binaryClient(7, "lorem");
    m.expectCalled().withValues(9, "lorem_foo");

    //1st value wrong, throw
    binaryClient(9, "ipsum");
    REQUIRE_THROWS(m.expectCalled().withValues(9, "ipsum_foo"));

    //2nd value wrong, throw
    binaryClient(9, "ipsum");
    REQUIRE_THROWS(m.expectCalled().withValues(11, "lorem_foo"));

    //both values ok
    binaryClient(9, "ipsum");
    m.expectCalled().withValues(11, "ipsum_foo");
}


TEST_CASE("withValues with initializer list") {
    auto m = MOCK(binary);
    for(int i = 0; i < 2; ++i) binaryClient(i, "toto");
    m.expectCalled(2).withValues({make_tuple(2, "toto_foo"), make_tuple(3, "toto_foo")});
}

TEST_CASE("withValues with variadic parameter list after multiple calls") {
    auto m = MOCK(binary);
    for(int i = 0; i < 3; ++i) binaryClient(i, "toto");
    m.expectCalled(3).withValues(2, "toto_foo");
}


TEST_CASE("Right exception message when withValues has wrong argument list size") {
    auto m = MOCK(binary);
    for(int i = 0; i < 2; ++i) binaryClient(i, "toto");
    try {
        m.expectCalled(2).withValues({make_tuple(3, "toto_foo"), make_tuple(3, "toto_foo"), make_tuple(3, "toto_foo")});
        REQUIRE(false); //should never get here
    } catch(const std::logic_error& ex) {
        REQUIRE(ex.what() == "ParamChecker::withValues called with 3 values, expected 2"s);
    }
}


TEST_CASE("Right exception message when invocation values don't match") {
    auto m = MOCK(binary);
    for(int i = 0; i < 2; ++i) binaryClient(i, "toto");
    try {
        m.expectCalled(2).withValues({make_tuple(1, "toto_foo"), make_tuple(3, "toto_foo")});
        REQUIRE(false); //should never get here
    } catch(const MockException& ex) {
        REQUIRE(ex.what() == "Invocation values do not match"s);
    }
}
