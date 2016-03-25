premock
=======

[![Build Status](https://travis-ci.org/atilaneves/premock.png?branch=master)](https://travis-ci.org/atilaneves/premock)

This header library makes it possible to replace implementations of C
and C++ functions with C++ callables for unit testing.

It works by using the preprocessor to redefine the functions to be
mocked in the files to be tested by prepending `ut_` to them instead
of calling the "real" implementation. This `ut_` function then
forwards to a `std::function` of the appropriate type that can be
changed at runtime to a C++ callable.

An example of mocking the BSD socket API `send` function would be to
have a header like this:


```c
#ifndef MOCK_NETWORK_H
#define MOCK_NETWORK_H
#    define send ut_send
#endif
```

The build system would then insert this header before any other
`#includes` via an option to the compiler (`-include` for gcc/clang).
This could also be done with `-D` but in the case of multiple
functions it's easier to have all the redefinitions in one header.

Now all calls to `send` are actually to `ut_send`. This will fail to
link since `ut_send` doesn't exist. To implement it, the test binary
should be linked with an object file from compiling this code
(e.g. called `mock_network.cpp`):

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

In this example, `PREMOCK_ENABLE` should not be defined for the
`mock_*.cpp` files so they have access to the "real" `send`.  Now
test code can do this:

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
    m.expectCalled().withValues(3, nullptr, 0, 0);
}

TEST(send, for_reals) {
    //no MOCK or REPLACE, calling a function that calls send
    //will call the real McCoy
    function_that_calls_send(); //this will probably send packets
}
```

If neither `REPLACE` nor `MOCK` are used, the original implementation
will be used.

Please consult the [example test file](example/test/test.cpp) or
the [unit tests](tests) for more.
