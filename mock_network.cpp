#include "mock_network.hpp"

using namespace std;

function<ssize_t(int, const void *, size_t, int)> mock_send = send;

ssize_t ut_send(int socket, const void *buffer, size_t length, int flags) {
    return mock_send(socket, buffer, length, flags);
}
