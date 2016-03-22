#ifndef MOCK_NETWORK_HPP_
#define MOCK_NETWORK_HPP_

#include "mock.hpp"
#include "mock_network.h"
#include <functional>

extern std::function<ssize_t(int, const void *, size_t, int)> mock_send;

#endif // MOCK_NETWORK_HPP_
