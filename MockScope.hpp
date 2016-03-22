#ifndef MOCK_SCOPE_HPP_
#define MOCK_SCOPE_HPP_

#include <functional>

/**
 RAII class for setting a mock to a callable until the end of scope
 */
template<typename T>
class MockScope {
public:

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

#endif
