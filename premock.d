module premock;

import std.traits;



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
    return MockScope!(mockType!func)(mock_func, newFunc);
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
    this(ref T func) {
        import std.array;

        _returns = [ReturnType!T.init];
        ReturnType!T inner(ParameterTypeTuple!T values) {
            auto ret = _returns[0];
            if(_returns.length > 1) _returns.popFront;
            return ret;
        }
        _scope = MockScope!(T)(func, &inner);
    }

    void returnValue(V...)(V value) {
        _returns.length = 0;
        foreach(v; value) _returns ~= v;
    }

    MockScope!T _scope;
    ReturnType!T[] _returns;
}

auto mock(string func)() {
    mixin("alias mock_func = " ~ mockName(func) ~ ";");
    return Mock!(typeof(mock_func))(mock_func);
}


@("mock returnValue")
unittest {
    {
        import std.stdio;
        import std.conv;

        //auto m = mock!"twice";
        auto m = Mock!(typeof(mock_twice))(mock_twice);
        // since no return value is set, it returns the default int, 0
        assert(mock_twice(3) == 0);

        m.returnValue(42);
        import std.conv;

        assert(mock_twice(3) == 42, text(mock_twice(3)));

        //calling it again should yield the same value
        assert(mock_twice(3) == 42);

        m.returnValue(7, 42, 99);
        assert(mock_twice(3) == 7);
        assert(mock_twice(3) == 42);
        assert(mock_twice(3) == 99);
    }
    assert(mock_twice(3) == 6); //should return to default implementation
}
