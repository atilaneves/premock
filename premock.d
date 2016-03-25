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

auto replace(string func)(int delegate(int) newFunc) {
    enum mock_name = "mock_" ~ func;
    mixin("alias mock_func = " ~ mock_name ~ ";");
    return MockScope!(typeof(mock_func))(mock_func, newFunc);
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
        auto _ = replace!("twice")((int i) { return i * 3; });
        assert(mock_twice(3) == 9);
    }
    assert(mock_twice(3) == 6); //should return to default implementation
}
