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

    import std.traits;

    this(ref T func) {

        _returns = [ReturnType!T.init];

        ReturnType!T inner(ParameterTypeTuple!T values) {
            import std.array;

            import std.stdio;
            writeln("returns length: ", _returns.length);
            writeln("returns ptr: ", &_returns);
            writeln("returns length: ", _returns.length);
            writeln("returns ptr: ", &_returns);

            //writeln("returns: ", _returns);
            //writeln("returns: ", &_returns);
            writeln("huh? returns length: ", _returns.length);
            auto ret = _returns[0];
            if(_returns.length > 1) {
                writeln("huh? returns length: ", _returns.length);
                _returns.popFront;
            }

            // writeln("returns: ", _returns);
            // //writeln("returns: ", &_returns);


            writeln("Otay. ret: ", ret);
            return ret;
        }


        _scope = MockScope!(typeof(func))(func, &inner);
    }

    void returnValue(V...)(V values) {
        import std.stdio;
        writeln("resetting");
        _returns.length = 0;
        foreach(v; values) _returns ~= v;
    }

private:

    MockScope!T _scope;
    ReturnType!T[] _returns;
}

auto mock(string func)() {
    mixin("alias mock_func = " ~ mockName(func) ~ ";");
    return Mock!(mockType!func)(mock_func);
}


@("mock returnValue")
unittest {
    {
        import std.stdio;

        auto m = mock!"twice";

        // since no return value is set, it returns the default int, 0
        assert(mock_twice(3) == 0);
        writeln("good stuff");

        m.returnValue(42);
        import std.conv;

        assert(mock_twice(3) == 42, text(mock_twice(3)));

        // //calling it again should yield the same value
        // assert(mock_twice(3) == 42);

        // m.returnValue(7, 42, 99);
        // assert(mock_twice(3) == 7);
        // assert(mock_twice(3) == 42);
        // assert(mock_twice(3) == 99);

    }
    // assert(mock_twice(3) == 6); //should return to default implementation
}
