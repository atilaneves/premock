#ifndef MOCK_HPP_
#define MOCK_HPP_


#include "MockScope.hpp"
#include <functional>
#include <type_traits>


template<typename F>
struct StdFunctionTypeImpl;

template<typename R, typename... A>
struct StdFunctionTypeImpl<R(*)(A...)> {
    using Type = std::function<R(A...)>;
};

/**
 Alias for the std::function type corresponding to the function pointer
 type F, e.g.

 int foo(int, float);
 static_assert(std::is_same<StdFunctionType<decltype(&foo)>, std::function<int(int, float>>);
 */
template<typename F>
using StdFunctionType = typename StdFunctionTypeImpl<F>::Type;


/**
 Temporarily replace func with the passed-in lambda:
 e.g.
 auto mock = MOCK(send, [](auto...) { return -1; })
 This causes every call to `send` in the production code to
 return -1 no matter what
 */
#define MOCK(func, lambda) mockScope(mock_##func, lambda)

/**
 Declares a mock function. The parameters are the function name and
 the types of its parameters. This is simply the declaration, the
 implementation is done with IMPL_MOCK. e.g.
 int foo(int, float);
 extern std::function<int(int, float)> mock_foo;
 */
#define DECL_MOCK(func) extern StdFunctionType<decltype(&func)> mock_##func

/**
 Definition of the std::function that will store the implementation.
 Defaults to the "real" function. e.g.
 int foo(int, float);
 std::function<int(int, float)> mock_foo = foo;
 */
#define MOCK_STORAGE(func) decltype(mock_##func) mock_##func = func

#define IMPL_MOCK_4(func, R, T1, T2, T3, T4) \
    MOCK_STORAGE(func); \
    R ut_##func(T1 a1, T2 a2, T3 a3, T4 a4) { \
        return mock_##func(a1, a2, a3, a4); \
    }



#endif // MOCK_HPP_
