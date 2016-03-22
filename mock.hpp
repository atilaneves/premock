#ifndef MOCK_HPP_
#define MOCK_HPP_

#include "mock.h"
#include "MockScope.hpp"
#include <functional>

#define MOCK(func_name, lambda) \
    mockScope(mock_##func_name, lambda)

extern std::function<ssize_t(int, const void *, size_t, int)> mock_send;


#endif // MOCK_HPP_
