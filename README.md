premock
=======

| [![Build Status](https://travis-ci.org/atilaneves/premock.png?branch=master)](https://travis-ci.org/atilaneves/premock) |  [![Build Status](https://ci.appveyor.com/api/projects/status/github/atilaneves/premock?branch=master&svg=true)](https://ci.appveyor.com/project/atilaneves/premock) |


This header-only (C++) / single-module (D) library makes it possible
to replace implementations of C functions (and C++ free functions)
with C++ or D callables (functions, lambdas, function objects) for
unit testing.

The motivation for premock is to write new tests for legacy C
codebases that were not written with testability in mind.  The example
with `send` below is indicative of that. I would expect newly written
code to not have a hard-coded IO call in the middle of its implementation.

It works by using the preprocessor to redefine the functions to be
mocked in the files to be tested by prepending `ut_premock_` to them instead
of calling the "real" implementation. This `ut_premock_` function then
forwards to a `std::function` / `delegate` of the appropriate type
that can be changed at runtime to a C++/D callable, respectively.

An example of mocking the BSD socket API `send` function would be to
have a header like this:


```c
#ifndef MOCK_NETWORK_H
#define MOCK_NETWORK_H
#    define send ut_premock_send
#endif
```

The build system would then insert this header before any other
`#includes` via an option to the compiler (`-include` for gcc/clang).
This could also be done with `-D` but in the case of multiple
functions it's easier to have all the redefinitions in one header.

Now all calls to `send` are actually to `ut_premock_send`. This will fail to
link since `ut_premock_send` doesn't exist. To implement it in C++ (see below
for D), the test binary should be linked with an object file from
compiling this code (e.g. called `mock_network.cpp`):

```c++
#include "mock_network.hpp"
extern "C" IMPL_MOCK(4, send); // the 4 is the number of parameters "send" takes
```

This will only compile if a header called `mock_network.hpp` exists with the
following contents:

```c++
#include "premock.hpp"
#include <sys/socket.h> // to have access to send, the original function
DECL_MOCK(send); // the declaration for the implementation in the cpp file
```

Now test code can do this:

```c++
#include "mock_network.hpp"

TEST(send, replace) {
    REPLACE(send, [](auto...) { return 7; });
    // any function that calls send from here until the end of scope
    // will call our lambda instead and always return 7
}

TEST(send, mock) {
    auto m = MOCK(send);
    m.returnValue(42);
    // any function that calls send from here until the end of scope
    // will get a return value of 42
    function_that_calls_send();
    // check last call to send only
    m.expectCalled().withValues(3, nullptr, 0, 0); //checks values of last call
    // check last 3 calls:
    m.expectCalled(3).withValues({make_tuple(3, nullptr, 0, 0),
                                  make_tuple(5, nullptr, 0, 0),
                                  make_tuple(7, nullptr, 0, 0)});
}

TEST(send, for_reals) {
    //no MOCK or REPLACE, calling a function that calls send
    //will call the real McCoy
    function_that_calls_send(); //this will probably send packets
}
```

If neither `REPLACE` nor `MOCK` are used, the original implementation
will be used.

Please consult the [example test file](example/cpp/test/test.cpp) or
the [unit tests](tests) for more.


In D, it's simpler, one module (e.g. `mock_network.d`) would have to do this:

```d
import premock;
mixin ImplCMock!("send", long, int, const(void)*, size_t, int);
```

The D version has the function signature. That's because for the
function to be usable in D it'd have to be declared anyway whereas C++
can just `#include` the relevant header.

The D equivalents of `MOCK` and `REPLACE` macros are the `mock` and `replace`
template mixins:

```d
unittest {
    mixin replace!("send", (a, b, c, d) => 7);
    // any function calling send from here until the end of scope
    // will call our lambda instead and always return 7
}

unittest {
    mixin mock!"send"; // creates a local variable called "m"
    m.returnValue(42);
    function_that_calls_send();
    // check last call to send only
    m.expectCalled.withValues(3, cast(const(void*))null, 0UL, 0);
    // check last 3 calls
    import std.typecons; // for tuple
    m.expectCalled().withValues(tuple(...), tuple(...), tuple(...));
}
```

Please consult the [example test file](example/d/test.d) and the unit tests
in [implementation](premock.d) for more.
