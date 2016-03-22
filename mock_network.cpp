#include "mock_network.hpp"

using namespace std;

IMPL_MOCK(send);

ssize_t ut_send(int socket, const void *buffer, size_t length, int flags) {
    return mock_send(socket, buffer, length, flags);
}
