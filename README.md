premock
=======

[![Build Status](https://travis-ci.org/atilaneves/premock.png?branch=master)](https://travis-ci.org/atilaneves/premock)

This header library makes it possible to replace implementations of C
functions with C++ callables for unit testing.

It works by using the preprocessor to redefine the functions to be
mocked in the files to be tested by prepending "ut_" to them instead
of calling the "real" implementation. This "ut_" function then
forwards to a std::function of the appropriate type that can be
changed in runtime to a C++ callable.

An example of mocking the BSD socket API `send` function would be to
have a header like this:


```c
#ifdef PREMOCK_ENABLE
#    define send ut_send
#endif
#include <sys/socket.h>
```

The build system would then insert this header before any other
#includes via an option to the compiler (`-include` for gcc/clang)

Now all calls to `send` are actually to `ut_send`. This will fail to
link since `ut_send` doesn't exist. To implement it, the test binary
should be linked with an object file from compiling this code
(`mock_network.cpp`):

```c++
#include "mock_network.hpp"
IMPL_MOCK(4, send); // the 4 is the number of parameters "send" takes
```

This will only compile if a header called `mock_network.hpp` exists with the
following contents:

```c++
#include "mock_network.h" // the header mentioned above where send -> ut_send
#include "premock.hpp"
DECL_MOCK(send); // the declaration for the implementation in the cpp file
```

In this example, the build system should pass `-DDISABLE_MOCKS` when
compiling `mock_network.cpp` so that it has access to the "real"
`send`. Now test code can do this:

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

```

Please consult the [example test file](example/test/test.cpp) or
the [unit tests](tests) for more.
