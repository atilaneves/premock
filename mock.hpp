#ifndef MOCK_HPP_
#define MOCK_HPP_


#include "MockScope.hpp"
#include <functional>


/**
 Temporarily replace func with the passed-in lambda:
 e.g.
 auto mock = MOCK(send, [](auto...) { return -1; })
 This causes every call to `send` in the production code to
 return -1 no matter what
 */
#define MOCK(func, lambda) mockScope(mock_##func, lambda)

/**
 Enables mocking by declaring the std::function that will be
 called by the production code.
 */
#define IMPL_MOCK(func) decltype(mock_##func) mock_##func = func


#endif // MOCK_HPP_
