module premock;


struct MockScope(T) {
    this(T)(ref T oldFunc, T newFunc) {
        _oldFuncPtr = &oldFunc;
        _oldFunc = oldFunc;
        oldFunc = newFunc;
    }

    ~this() {
        *_oldFuncPtr = _oldFunc;
    }

 private:

    T* _oldFuncPtr;
    T _oldFunc;
}

private string mockName(in string func) {
    return "mock_" ~ func;
}

private alias mockType(string func) = typeof(mixin(mockName(func)));

auto mockScope(string func)(mockType!func newFunc) {
    mixin("alias mock_func = " ~ mockName(func) ~ ";");
    return MockScope!(typeof(mock_func))(mock_func, newFunc);
}

mixin template Replace(string func, string newFunc) {
    auto _ = mockScope!(func)(mixin(newFunc));
}

version(unittest) {
    int delegate(int) mock_twice;

    static this() {
        mock_twice = (i) => i * 2;
    }
}

@("replace works correctly")
unittest {
    import std.conv;
    {
        mixin Replace!("twice", q{i => i * 3});
        assert(mock_twice(3) == 9);
    }
    assert(mock_twice(3) == 6); //should return to default implementation
}


struct Mock(T) {
    void returnValue(V...)(V) {

    }
}

auto mock(string func)() {
    return Mock!(mockType!func)();
}


@("mock returnValue")
unittest {
    {
        auto m = mock!"twice";

        // since no return value is set, it returns the default int, 0
        assert(mock_twice(3) == 0);

        m.returnValue(42);
        assert(mock_twice(3) == 42);

        //calling it again should yield the same value
        assert(mock_twice(3) == 42);

        m.returnValue(7, 42, 99);
        assert(mock_twice(3) == 7);
        assert(mock_twice(3) == 42);
        assert(mock_twice(3) == 99);

    }
    assert(mock_twice(3) == 6); //should return to default implementation
}
