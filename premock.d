module premock;


import std.traits;
import std.typecons;


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
        import std.stdio;

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

    auto expectCalled(int n = 1) {
        struct ParamChecker {
            void withValues(V...)(V values) {

            }
        }
        return ParamChecker();
    }

    MockScope!T _scope;
    ReturnType!T[] _returns;
}


mixin template mock(string func, string varName = "m") {
    enum autoDecl = "auto " ~ varName;
    mixin(autoDecl ~ q{ = Mock!(typeof(mixin(mockName(func))))(mixin(mockName(func))); });
}

@("mock returnValue")
unittest {
    {
        import std.stdio;
        import std.conv;

        mixin mock!"twice";

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

version(unittest) {
    private int twiceClient(int i) {
        return mock_twice(i + 1);
    }
}

@("MOCK expect calls to twice")
unittest {
    import std.exception;

    mixin mock!"twice";

    assertThrown(m.expectCalled()); //hasn't been called yet, so...

    twiceClient(2); //calls mock_twice internally
    m.expectCalled().withValues(3);
    assertThrown(m.expectCalled()); //was called once, not twice

    for(int i = 0; i < 5; ++i) twiceClient(i);
    m.expectCalled(5).withValues(tuple(1), tuple(2), tuple(3), tuple(4), tuple(5));
}
