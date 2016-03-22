#ifndef MOCK_HPP_
#define MOCK_HPP_

#include "mock.h"
#include "MockScope.hpp"

#include <functional>

extern std::function<ssize_t(int, const void *, size_t, int)> mock_send;


#endif // MOCK_HPP_
