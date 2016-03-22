#ifndef MOCK_NETWORK_HPP_
#define MOCK_NETWORK_HPP_

#include "mock.hpp"
#include "mock_network.h"
#include <functional>

DECL_MOCK(send, ssize_t, int, const void*, size_t, int);

#endif // MOCK_NETWORK_HPP_
