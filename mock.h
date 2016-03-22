#ifndef MOCK_H_
#define MOCK_H_

#ifdef __cplusplus
extern "C" {
#endif

#include <sys/socket.h>

ssize_t ut_send(int socket, const void *buffer, size_t length, int flags);

#ifndef DISABLE_MOCKS
#    define send ut_send
#endif


#ifdef __cplusplus
}
#endif


#endif // MOCK_H_
