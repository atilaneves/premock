#ifndef MOCK_HPP_
#define MOCK_HPP_

#include <sys/socket.h>

ssize_t ut_send(int socket, const void *buffer, size_t length, int flags);

#define send ut_send


#endif // MOCK_HPP_
