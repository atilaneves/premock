/**
 This header makes it possible to replace implementations of C functions with C++
 callables for unit testing.

 It works by using the preprocessor to redefine the functions to be mocked in
 the files to be tested by prepending "ut_" to them instead of calling the "real"
 implementation. This "ut_" function then forwards to a std::function of the
 appropriate type that can be changed in runtime to a C++ callable.

 An example of mocking the BSD socket API "send" function would be to have
 a header like this:


 #ifdef PREMOCK_ENABLE
 #    define send ut_send
 #endif
 #include <sys/socket.h>


 Which the build system would insert before any other #includes via an option
 to the compiler (-include for gcc/clang)

 Now all calls to "send" are actually to "ut_send". This will fail to link since
 "ut_send" doesn't exist. To implement it, the test binary should be linked with
 an object file from compiling this code (mock_network.cpp):


 #include "mock_network.hpp"
 IMPL_MOCK(4, send) // the 4 is the number of parameters send takes


 This will only compile if a header called "mock_network.hpp" exists with the
 following contents:

 #include "mock_network.h" // the header mentioned above where send -> ut_send
 #include "premock.hpp"
 DECL_MOCK(send); // the declaration for the implementation in the cpp file


 In this example, the build system should pass -DDISABLE_MOCKS when compiling
 mock_network.cpp so that it has access to the "real" send. Now test code can do
 this:


 #include "mock_network.hpp"
 auto _ = REPLACE(send, [](auto...) { return 7; });
 // any function that calls send from here until the end of scope
 // will call our lambda instead and always return 7

 */

#ifndef MOCK_HPP_
#define MOCK_HPP_


#include <functional>
#include <type_traits>
#include <tuple>
#include <deque>
#include <stdexcept>


/**
 RAII class for setting a mock to a callable until the end of scope
 */
template<typename T>
class MockScope {
public:

    using ReturnType = typename T::result_type;

    template<typename F>
    MockScope(T& func, F scopeFunc):
        _func{func},
        _oldFunc{std::move(func)} {

        _func = std::move(scopeFunc);
    }


    ~MockScope() {
        _func = std::move(_oldFunc);
    }

private:

    T& _func;
    T _oldFunc;
};


/**
 Helper function to create a MockScope
*/
template<typename T, typename F>
MockScope<T> mockScope(T& func, F scopeFunc) {
    return {func, scopeFunc};
}

/**
 Temporarily replace func with the passed-in lambda:
 e.g.
 auto mock = REPLACE(send, [](auto...) { return -1; })
 This causes every call to `send` in the production code to
 return -1 no matter what
 */
#define REPLACE(func, lambda) auto _ = mockScope(mock_##func, lambda)

template<typename>
struct StdFunctionTraits {};

/**
 Pattern match on std::function to get its parameter types
 */
template<typename R, typename... A>
struct StdFunctionTraits<std::function<R(A...)>> {
    using TupleType = std::tuple<A...>;
};

#include <string>
template<typename T>
class Mock {
public:

    using ReturnType = typename MockScope<T>::ReturnType;
    using TupleType = typename StdFunctionTraits<T>::TupleType;

    class ParamChecker {
        public:

        ParamChecker(std::deque<TupleType> v):_values{v} {}

        template<typename... A>
        void withValues(A... args) {
            withValues({std::make_tuple(args...)}, _values.size() - 1, _values.size());
        }

        void withValues(std::initializer_list<TupleType> args,
                        size_t start = 0, size_t end = 0) {
            std::deque<TupleType> expected{args};
            if(expected.size() != args.size()) throw std::logic_error("Wrong size in withValues");
            if(end == 0) end = expected.size();
            for(size_t i = start; i < end; ++i) {
                if(expected[i] != _values[i])
                    throw std::logic_error("Called values do not match");
            }
        }

        private:

        std::deque<TupleType> _values;
    };

    Mock(T& func):
        _mockScope{func,
            [this](auto... args) {
                _values.emplace_back(args...);
                ++_numCalls;
                auto ret = _returns[0];
                if(_returns.size()) _returns.pop_front();
                return ret;
        }} {

    }

    void returnValue(ReturnType r) { _returns.push_back(r); }

    template<typename A, typename... As>
    void returnValues(A arg, As... args) {
        _returns.push_back(arg);
        returnValues(args...);
    }

    void returnValues() {
    }

    ParamChecker expectCalled(int n = 1) {

        if(_numCalls != n) throw std::logic_error("Was not called enough times");
        _numCalls = 0;

        return {_values};
    }

private:

    MockScope<T> _mockScope;
    std::deque<ReturnType> _returns;
    int _numCalls{};
    std::deque<TupleType> _values;
};

template<typename T>
Mock<T> mock(T& func) {
    return {func};
}

#define MOCK(func) mock(mock_##func)

/**
 Traits class for functions
 */
template<typename>
struct FunctionTraits;

template<typename R, typename... A>
struct FunctionTraits<R(*)(A...)> {
    /**
     The corresponding type of a std::function that the function could be assigned to
     */
    using StdFunctionType = std::function<R(A...)>;

    /**
     The return type of the function
     */
    using ReturnType = R;

    /**
     Helper struct to get the type of the Nth argument to the function
     */
    template<int N>
    struct Arg {
        using Type = std::remove_reference_t<decltype(std::get<N>(std::tuple<A...>()))>;
    };
};


/**
 Declares a mock function for "real" function func. This is simply the
 declaration, the implementation is done with IMPL_MOCK. If foo has signature:

 int foo(int, float);

 Then DECL_MOCK(foo) is:

 extern std::function<int(int, float)> mock_foo;
 */
#define DECL_MOCK(func) extern FunctionTraits<decltype(&func)>::StdFunctionType mock_##func

/**
 Definition of the std::function that will store the implementation.
 Defaults to the "real" function. e.g. given:

 int foo(int, float);

 Then MOCK_STORAGE(foo) is:

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
