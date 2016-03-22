#ifndef MOCK_HPP_
#define MOCK_HPP_


#include "MockScope.hpp"
#include <functional>
#include <type_traits>

template <typename F>
struct ReturnTypeImpl;

template<typename R, typename... A>
struct ReturnTypeImpl<R(*)(A...)> {
    using Type = R;
};

template<typename T>
using ReturnType = typename ReturnTypeImpl<T>::Type;


/**
 Temporarily replace func with the passed-in lambda:
 e.g.
 auto mock = MOCK(send, [](auto...) { return -1; })
 This causes every call to `send` in the production code to
 return -1 no matter what
 */
#define MOCK(func, lambda) mockScope(mock_##func, lambda)

/**
 Enables mocking by declaring the std::function that will be
 called by the production code.
 */
#define MOCK_STORAGE(func) decltype(mock_##func) mock_##func = func

#define DECL_MOCK(func, ...) extern std::function<ReturnType<decltype(&func)>(__VA_ARGS__)> mock_##func

#define IMPL_MOCK_4(func, R, T1, T2, T3, T4) \
    MOCK_STORAGE(func); \
    R ut_##func(T1 a1, T2 a2, T3 a3, T4 a4) { \
        return mock_##func(a1, a2, a3, a4); \
    }



#endif // MOCK_HPP_
