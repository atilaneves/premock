#ifndef MOCK_NETWORK_H_
#define MOCK_NETWORK_H_

#ifdef __cplusplus
extern "C" {
#endif

#ifndef DISABLE_MOCKS
#    define send ut_send
#endif

#include <sys/socket.h>


#ifdef __cplusplus
}
#endif



#endif // MOCK_NETWORK_H_
