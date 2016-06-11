//so that the types are visible when including premock

#include <iostream>

namespace {
struct Foo {
    Foo(int _i):i{_i} {}
    int i;
    bool operator==(const Foo& other) const noexcept { return i == other.i; }
};
struct Bar {
    Bar(int _i):i{_i} {}
    int i;
    bool operator==(const Bar& other) const noexcept { return i == other.i; }
};
}

std::ostream& operator<<(std::ostream& stream, const Foo& foo) {
    stream << "Foo{" << foo.i << "}";
    return stream;
}

void useStream() {
    // just so operator<< above is used by someone and the compiler stops complaining
    std::cout << Foo{1};
}


#include "catch.hpp"
#include "premock.hpp"
#include <functional>
#include <string>

static_assert(CanBeStreamed<Foo>::value, "Foo should be able to be streamed");
static_assert(!CanBeStreamed<Bar>::value, "Bar should not be able to be streamed");


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
    for(int i = 0; i < 3; ++i) binaryClient(i, "boom");
    m.expectCalled(3).withValues(4, "boom_foo");
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
        REQUIRE(ex.what() ==
                "Invocation values do not match\n"s +
                "Expected: (1, toto_foo)\n" +
                "Actual:   (2, toto_foo)\n");
    }
}


static function<bool(const Foo&, const string&)> mock_foo = [](const Foo&, const string&) { return false; };
static bool fooClient(const Foo& foo, const string& str) {
    return mock_foo(Foo{foo.i * 2}, str + "_foo");
}

TEST_CASE("Right exception message when invocation values don't match for streamable values") {
    auto m = MOCK(foo);
    for(int i = 0; i < 3; ++i) fooClient(Foo{7 + i}, to_string(i));
    try {
        m.expectCalled(3).withValues({make_tuple(Foo{14}, "0_foo"), make_tuple(Foo{17}, "1_foo"), make_tuple(Foo{18}, "2_foo")});
        REQUIRE(false); //should never get here
    } catch(const MockException& ex) {
        REQUIRE(ex.what() ==
                "Invocation values do not match\n"s +
                "Expected: (Foo{17}, 1_foo)\n" +
                "Actual:   (Foo{16}, 1_foo)\n");
    }
}

static function<bool(const Bar&)> mock_bar = [](const Bar&) { return false; };
static bool barClient(const Bar& bar) { return mock_bar(Bar{bar.i * 3}); }

TEST_CASE("Right exception message when invocation values don't match for unstreamable values") {
    auto m = MOCK(bar);
    barClient(Bar{7});
    try {
        m.expectCalled().withValues(Bar{20}); //actually 21
        REQUIRE(false); //should never get here
    } catch(const MockException& ex) {
        REQUIRE(ex.what() ==
                "Invocation values do not match\n"s +
                "Expected: (<cannot print>)\n" +
                "Actual:   (<cannot print>)\n");
    }
}

static function<bool(char* output)> mock_output_string;
static const char* returnString() {
    static char buf[200] = "deadbeef";
    mock_output_string(buf);
    return buf;
}


TEST_CASE("output c string") {
    auto m = MOCK(output_string);
    char buf[] = "foobar";
    m.outputArray<0>(buf, strlen(buf) + 1);
    REQUIRE(returnString() == "foobar"s);
}

static function<bool(int, int*)> mock_output_int;
static int returnDoubleInt(int i) {
    static int o = 11223344;
    mock_output_int(i, &o);
    return o * 2;
}

TEST_CASE("output int") {
    auto m = MOCK(output_int);
    int val{21};
    m.outputParam<1>(&val);
    REQUIRE(returnDoubleInt(5) == 42);
    m.expectCalled();//.withValues(5, nullptr);
}


static function<void(int)> mock_void_return;
static void callDoubleInt(int i) { mock_void_return(i * 2); }

TEST_CASE("void return") {
    auto m = MOCK(void_return);
    callDoubleInt(5);
    m.expectCalled().withValues(10);
}
