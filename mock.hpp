#ifndef MOCK_HPP_
#define MOCK_HPP_


#include "mock.h"
#include "MockScope.hpp"
#include <functional>


#define MOCK(func_name, lambda) \
    mockScope(mock_##func_name, lambda)


#endif // MOCK_HPP_
