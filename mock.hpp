#ifndef MOCK_HPP_
#define MOCK_HPP_

#include <sys/socket.h>

ssize_t ut_send(int socket, const void *buffer, size_t length, int flags);

#ifndef DISABLE_MOCKS
#    define send ut_send
#endif

#endif // MOCK_HPP_
