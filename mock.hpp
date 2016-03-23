#ifndef MOCK_HPP_
#define MOCK_HPP_


#include "MockScope.hpp"
#include <functional>
#include <type_traits>
#include <tuple>


template<typename F>
struct FunctionTraits;

template<typename R, typename... A>
struct FunctionTraits<R(*)(A...)> {
    using StdFunctionType = std::function<R(A...)>;
    using ReturnType = R;
    enum { Arity = sizeof...(A) };

    template<int N>
    struct Arg {
        using Type = std::remove_reference_t<decltype(std::get<N>(std::tuple<A...>()))>;
    };
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

/**
 A name for the ut_ function argument at position index
 */
#define UT_FUNC_ARG(index) arg_##index

/**
 Type and name for ut_ function argument at position index
 */
#define UT_FUNC_TYPE_AND_ARG(func, index) FunctionTraits<decltype(&func)>::Arg<index>::Type UT_FUNC_ARG(index)


/**
 Helper macros to generate the code for the ut_ functions.
 UT_FUNC_ARGS_N generates the parameter list in the function declaration,
 with types and parameter names, e.g. (int arg0, float arg1, ...)
 UT_FUNC_FWD_N generates just the parameter names so that the ut_
 function can forward the call to the equivalent mock_
 */
#define UT_FUNC_ARGS_0(func)
#define UT_FUNC_FWD_0

#define UT_FUNC_ARGS_1(func) UT_FUNC_ARGS_0(func) UT_FUNC_TYPE_AND_ARG(func, 0)
#define UT_FUNC_FWD_1 UT_FUNC_FWD_0 UT_FUNC_ARG(0)

#define UT_FUNC_ARGS_2(func) UT_FUNC_ARGS_1(func), UT_FUNC_TYPE_AND_ARG(func, 1)
#define UT_FUNC_FWD_2 UT_FUNC_FWD_1, UT_FUNC_ARG(1)

#define UT_FUNC_ARGS_3(func) UT_FUNC_ARGS_2(func), UT_FUNC_TYPE_AND_ARG(func, 2)
#define UT_FUNC_FWD_3 UT_FUNC_FWD_2, UT_FUNC_ARG(2)

#define UT_FUNC_ARGS_4(func) UT_FUNC_ARGS_3(func), UT_FUNC_TYPE_AND_ARG(func, 3)
#define UT_FUNC_FWD_4 UT_FUNC_FWD_3, UT_FUNC_ARG(3)

#define UT_FUNC_ARGS_5(func) UT_FUNC_ARGS_4(func), UT_FUNC_TYPE_AND_ARG(func, 4)
#define UT_FUNC_FWD_5 UT_FUNC_FWD_4, UT_FUNC_ARG(4)

#define UT_FUNC_ARGS_6(func) UT_FUNC_ARGS_5(func), UT_FUNC_TYPE_AND_ARG(func, 5)
#define UT_FUNC_FWD_6 UT_FUNC_FWD_5, UT_FUNC_ARG(5)

#define UT_FUNC_ARGS_7(func) UT_FUNC_ARGS_6(func), UT_FUNC_TYPE_AND_ARG(func, 6)
#define UT_FUNC_FWD_7 UT_FUNC_FWD_6, UT_FUNC_ARG(6)

#define UT_FUNC_ARGS_8(func) UT_FUNC_ARGS_7(func), UT_FUNC_TYPE_AND_ARG(func, 7)
#define UT_FUNC_FWD_8 UT_FUNC_FWD_7, UT_FUNC_ARG(7)

#define UT_FUNC_ARGS_9(func) UT_FUNC_ARGS_8(func), UT_FUNC_TYPE_AND_ARG(func, 8)
#define UT_FUNC_FWD_9 UT_FUNC_FWD_8, UT_FUNC_ARG(8)


/**
 The implementation of the C++ mock for function func.
 This writes code to:

 1. Define the global mock_func std::function variable to hold the current implementation
 2. Assign this global to a pointer to the "real" implementation
 3. Writes the ut_ function called by production code to automatically forward to the mock

 The number of arguments that the function takes must be specified. This could be deduced
 with template metaprogramming but there is no way to feed that information back to
 the preprocessor. Since the production calling code thinks it's calling a function
 whose name begins with ut_, that function must exist or there'll be a linker error.
 The only way to not have to write the function by hand is to use the preprocessor.

 An example of a call to IMPL_MOCK(4, send) (where send is the BSD socket function):

 std::function<ssize_t(int, const void*, size_t, int)> mock_send = send;

 extern "C" ssize_t ut_send(int arg0, const void* arg1, size_t arg2, int arg3) {
     return mock_send(arg0, arg1, arg2, arg3);
 }

 */
#define IMPL_MOCK(num_args, func) \
    MOCK_STORAGE(func); \
    extern "C" FunctionTraits<decltype(&func)>::ReturnType ut_##func(UT_FUNC_ARGS_##num_args(func)) { \
        return mock_##func(UT_FUNC_FWD_##num_args); \
    }


#endif // MOCK_HPP_
