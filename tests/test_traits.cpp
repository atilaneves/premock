#include "catch.hpp"
#include "premock.hpp"


using namespace std;


TEST_CASE("StdFunctionTraits TupleType") {
    static_assert(is_same<StdFunctionTraits<function<int(string, double, const char*)>>::TupleType,
                          tuple<string, double, const char*>>::value, "Wrong std::function tuple type");
}


int func(string, double, const char*, int&, string&&);

TEST_CASE("FunctionTraits std::function type") {
    static_assert(is_same<FunctionTraits<decltype(&func)>::StdFunctionType,
                          function<int(string, double, const char*, int&, string&&)>>::value, "Wrong std::function type");
}


TEST_CASE("FunctionTraits return type") {
    static_assert(is_same<FunctionTraits<decltype(&func)>::ReturnType,
                          int>::value, "Wrong return type");
}


TEST_CASE("FunctionTraits parameter type") {
    static_assert(is_same<FunctionTraits<decltype(&func)>::Arg<0>::Type,
                          string>::value, "Wrong parameter type");

    static_assert(is_same<FunctionTraits<decltype(&func)>::Arg<1>::Type,
                          double>::value, "Wrong parameter type");

    static_assert(is_same<FunctionTraits<decltype(&func)>::Arg<2>::Type,
                          const char*>::value, "Wrong parameter type");
                          
    static_assert(is_same<FunctionTraits<decltype(&func)>::Arg<3>::Type,
                          int&>::value, "Wrong parameter type");

    static_assert(is_same<FunctionTraits<decltype(&func)>::Arg<4>::Type,
                          string&&>::value, "Wrong parameter type");
}
