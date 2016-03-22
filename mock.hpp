#ifndef MOCK_HPP_
#define MOCK_HPP_


#include "MockScope.hpp"
#include <functional>
#include <type_traits>


template<typename F>
struct FunctionTraits;

template<typename R, typename... A>
struct FunctionTraits<R(*)(A...)> {
    using StdFunctionType = std::function<R(A...)>;
    using ReturnType = R;
};


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
#define DECL_MOCK(func) extern FunctionTraits<decltype(&func)>::StdFunctionType mock_##func

/**
 Definition of the std::function that will store the implementation.
 Defaults to the "real" function. e.g.
 int foo(int, float);
 std::function<int(int, float)> mock_foo = foo;
 */
#define MOCK_STORAGE(func) decltype(mock_##func) mock_##func = func

#define UT_ARG(N) arg_##N


#define IMPL_MOCK_0(func) \
    MOCK_STORAGE(func); \
    extern "C" FunctionTraits<decltype(&func)>::ReturnType ut_##func() {  \
        return mock_##func(); \
    }

#define IMPL_MOCK_1(func, T0) \
    MOCK_STORAGE(func); \
    extern "C" FunctionTraits<decltype(&func)>::ReturnType ut_##func(T0 UT_ARG(0)) { \
        return mock_##func(UT_ARG(0)); \
    }

#define IMPL_MOCK_2(func, T0, T1) \
    MOCK_STORAGE(func); \
    extern "C" FunctionTraits<decltype(&func)>::ReturnType ut_##func(T0 UT_ARG(0), T1 UT_ARG(1)) { \
        return mock_##func(UT_ARG(0), UT_ARG(1)); \
    }


#define IMPL_MOCK_4(func, T0, T1, T2, T3)    \
    MOCK_STORAGE(func); \
    extern "C" FunctionTraits<decltype(&func)>::ReturnType ut_##func(T0 a0, T1 a1, T2 a2, T3 a3) { \
        return mock_##func(a0, a1, a2, a3); \
    }



#endif // MOCK_HPP_
