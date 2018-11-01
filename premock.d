module premock;


import std.traits;
import std.typecons;
import std.conv;
import std.exception;
import std.meta;

version(unittest) {
    import core.exception;
}


struct MockScope(T, alias F) if(isDelegate!T) {
    this(ref T oldFunc) {
        _scope = RunMockScope!T(oldFunc, toDelegate!(T, F));
    }

private:
    RunMockScope!T _scope;
}

struct RunMockScope(T) if(isDelegate!T) {

    this(U)(ref T oldFunc, U newFunc) {
        _oldFuncPtr = &oldFunc;
        _oldFunc = oldFunc;
        oldFunc = toDelegate!T(newFunc);
    }

    ~this() {
        *_oldFuncPtr = _oldFunc;
    }

 private:

    T* _oldFuncPtr;
    T _oldFunc;
}


private T toDelegate(T, alias F)() {
    static if(isDelegate!F)
        return F;
    else
        return (Parameters!T values) => F(values);
}

private T toDelegate(T, F)(F f) {
    static if(isDelegate!F)
        return f;
    else
        return (Parameters!T values) => f(values);
}


auto mockScope(alias F, T)(ref T oldFunc) {
    auto m = MockScope!(T, F)(oldFunc);
    return m;
}

mixin template replace(string func, alias F, string varName = "_") {
    mixin("auto " ~ varName ~ q{ = mockScope!F( } ~ mockName(func) ~ ");");
}

@("MockScope ctor/dtor") unittest {
    int delegate(int, string) mock_foo = (i, s) => i + cast(int)s.length;
    assert(mock_foo(7, "foo") == 10);

    {
        mixin replace!("foo", (i, s) => i + 1 - cast(int)s.length);
        assert(mock_foo(7, "foo") == 5, mock_foo(7, "foo").to!string);
    }

    assert(mock_foo(7, "foo") == 10);
}


string mockName(in string func) {
    return "mock_" ~ func;
}

alias mockType(string func) = typeof(mixin(mockName(func)));


version(unittest) {
    int delegate(int) mock_twice_ut;

    static this() {
        mock_twice_ut = (i) => i * 2;
    }
}


class MockException: Exception {
    this(string msg, string file = __FILE__, ulong line = cast(ulong)__LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}

struct Mock(T) {
    this(ref T func) {
        import std.array;

        static if(!is(ReturnType!T == void))
            _returns = [ReturnType!T.init];

        ReturnType!T inner(Parameters!T values) {
            _values ~= tuple(values);

            setOutputParameters(values);

            static if(!is(ReturnType!T == void)) {
                auto ret = _returns[0];
                if(_returns.length > 1) _returns.popFront;
                return ret;
            }
        }
        _scope = RunMockScope!(T)(func, &inner);
    }

    void returnValue(V...)(V value) {
        _returns.length = 0;
        foreach(v; value) _returns ~= v;
    }

    auto expectCalled(int n = 1, string file = __FILE__, ulong line = cast(ulong)__LINE__) {

        struct ParamCheck {

            Tuple!(Parameters!T)[] _values;

            void withValues(V...)(V values) if(is(V == Parameters!T)) {
                auto expected = tuple(values);
                if(expected != _values[$ - 1]) throwValueException(expected, _values[$ - 1]);
            }

            enum isParamTuple(U) = is(U == Tuple!(Parameters!T));

            void withValues(V...)(V values) if(allSatisfy!(isParamTuple, V)) {

                assert(V.length == _values.length,
                       text("ParamCheck.withValues called with ",
                            capitalize(V.length, "value"), ", expected ", _values.length));

                foreach(i, v; values) {
                    if(v != _values[i]) throwValueException(values[i], _values[i]);
                }
            }
        }

        if(_values.length != n) {
            throw new MockException(text("Was not called enough times\n",
                                         "Expected: ", n, "\n",
                                         "Actual:   ", _values.length, "\n"),
                                    file, line);
        }

        auto oldValues = _values;
        _values.length = 0;
        return ParamCheck(oldValues);
    }

    void outputParam(int index, A)(A* ptr) {
        outputArray!index(ptr, 1);
    }

    void outputArray(int index, A)(A* ptr, ulong length) {
        _outputs[index] = cast(void[])(ptr[0 .. length * A.sizeof]);
    }

private:

    RunMockScope!T _scope;
    ReturnType!T[] _returns;
    Tuple!(Parameters!T)[] _values;
    void[][Parameters!T.length] _outputs;

    static string capitalize(int val, string word) {
        return val == 1 ? "1 " ~ word : val.to!string ~ " " ~ word ~ "s";
    }

    static void throwValueException(U, V)(U expected, V actual) {
         throw new MockException(text("Invocation values do not match\n",
                                      "Expected: ", expected, "\n",
                                      "Actual:   ", actual, "\n"));
    }

    void setOutputParameters(A...)(A params) {
        foreach(i, ref param; params) {
            static if(isPointer!(typeof(param)) && !is(typeof(param) == const(V)*, V)) {
                import core.stdc.string;
                memcpy(param, _outputs[i].ptr, _outputs[i].length);
            }
        }
    }
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

        mixin mock!"twice_ut";

        // since no return value is set, it returns the default int, 0
        assert(mock_twice_ut(3) == 0);

        m.returnValue(42);
        import std.conv;

        assert(mock_twice_ut(3) == 42, text(mock_twice_ut(3)));

        //calling it again should yield the same value
        assert(mock_twice_ut(3) == 42);

        m.returnValue(7, 42, 99);
        assert(mock_twice_ut(3) == 7);
        assert(mock_twice_ut(3) == 42);
        assert(mock_twice_ut(3) == 99);
    }
    assert(mock_twice_ut(3) == 6); //should return to default implementation
}

version(unittest) {
    private int twiceClient(int i) {
        return mock_twice_ut(i + 1);
    }
}

@("MOCK expect calls to twice")
unittest {
    import std.exception;

    mixin mock!"twice_ut";

    assertThrown!MockException(m.expectCalled()); //hasn't been called yet, so...

    twiceClient(2); //calls mock_twice internally
    m.expectCalled().withValues(3);
    assertThrown!MockException(m.expectCalled()); //was called once, not twice

    for(int i = 0; i < 5; ++i) twiceClient(i);
    m.expectCalled(5).withValues(tuple(1), tuple(2), tuple(3), tuple(4), tuple(5));
}


version(unittest) {
    private int delegate(int, string) mock_binary;
    static this() {
        mock_binary = (i, s) => i + cast(int)s.length;
    }
    private int binaryClient(int i, string s) { return mock_binary(i + 2, s ~ "_foo"); }
}

@("mock expect calls to binary") unittest {
    mixin mock!"binary";

    binaryClient(7, "lorem");
    m.expectCalled().withValues(9, "lorem_foo");

    //1st value wrong, throw
    binaryClient(9, "ipsum");
    assertThrown!MockException(m.expectCalled().withValues(9, "ipsum_foo"));

    //2nd value wrong, throw
    binaryClient(9, "ipsum");
    assertThrown!MockException(m.expectCalled().withValues(11, "lorem_foo"));

    //both values ok
    binaryClient(9, "ipsum");
    m.expectCalled().withValues(11, "ipsum_foo");
}


@("withValues with initializer list") unittest {
    mixin mock!"binary";
    for(int i = 0; i < 2; ++i) binaryClient(i, "toto");
    m.expectCalled(2).withValues(tuple(2, "toto_foo"), tuple(3, "toto_foo"));
}

@("withValues with variadic parameter list after multiple calls") unittest {
    mixin mock!"binary";
    for(int i = 0; i < 3; ++i) binaryClient(i, "boom");
    m.expectCalled(3).withValues(4, "boom_foo");
}


@("Right exception message when withValues has wrong argument list size") unittest {
    mixin mock!"binary";
    for(int i = 0; i < 2; ++i) binaryClient(i, "toto");
    try {
        m.expectCalled(2).withValues(tuple(3, "toto_foo"), tuple(3, "toto_foo"), tuple(3, "toto_foo"));
        assert(false); //should never get here
    } catch(AssertError ex) {
        assert(ex.msg == "ParamCheck.withValues called with 3 values, expected 2");
    }
}


@("Right exception message when invocation values don't match") unittest {
    mixin mock!"binary";
    for(int i = 0; i < 2; ++i) binaryClient(i, "toto");
    try {
        m.expectCalled(2).withValues(tuple(1, "toto_foo"), tuple(3, "toto_foo"));
        assert(false); //should never get here
    } catch(MockException ex) {
        assert(ex.msg ==
               "Invocation values do not match\n" ~
               "Expected: Tuple!(int, string)(1, \"toto_foo\")\n" ~
               "Actual:   Tuple!(int, string)(2, \"toto_foo\")\n");
    }
}

@("output C string") unittest {
    bool delegate(int input, char* output) mock_output_string;
    string returnString(int i) {
        static char[200] buf = "deadbeef";
        mock_output_string(i, buf.ptr);
        import std.string;
        import std.conv: to;
        return buf.ptr.fromStringz.to!string;
    }

    mixin mock!"output_string";
    string buf = "foobar" ~ '\0';
    m.outputArray!(1)(buf.ptr, buf.length + 1);
    assert(returnString(5) == "foobar");
}

@("output int") unittest {
    bool delegate(int input, int* output) mock_output_int;
    int returnDoubleInt(int i) {
        static int o = 11223344;
        mock_output_int(i, &o);
        return o * 2;
    }
    mixin mock!"output_int";
    int val = 21;
    m.outputParam!(1)(&val);
    assert(returnDoubleInt(5) == 42);
    m.expectCalled;
}

@("void return type for mock") unittest {

    void delegate(int input) mock_func;
    void callDoubleInt(int i) { mock_func(i * 2); }
    mixin mock!"func";
    callDoubleInt(5);
    m.expectCalled.withValues(10);
}

private mixin template DeclareMock(string func, R, T...) {
    mixin(`pragma(mangle, "` ~ func ~ `")` ~ q{extern(C) R } ~ func ~ q{ (T); });
    mixin(q{R delegate(T) mock_} ~ func ~ ";"); //declare the mock
}

private mixin template ImplementUtFunc(string func, R, T...) {
    mixin(`pragma(mangle, "ut_premock_` ~ func ~ `")` ~ q{ extern(C) R ut_premock_} ~ func ~ typeAndArgsParens!T ~ " { " ~
          q{ return mock_} ~ func ~ argNamesParens(T.length) ~ ";" ~
          `}`);
}

mixin template ImplCMock(string func, R, T...) {
    mixin DeclareMock!(func, R, T);
    mixin ImplementUtFunc!(func, R, T);
}

mixin template ImplCMockDefault(string func, R, T...) {
    mixin DeclareMock!(func, R, T);
    static this() {
        mixin(`mock_` ~ func ~ ` = ` ~ argNamesParens(T.length) ~ ` => ` ~ func ~ argNamesParens(T.length) ~ ";");
    }
    mixin ImplementUtFunc!(func, R, T);
}


string implCppMockStr(string func, R, T...)() {
    return "extern(C++)" ~ R.stringof ~ " " ~ func ~ T.stringof ~ ";" ~ "\n" ~
                            R.stringof ~ " delegate" ~ T.stringof ~ " mock_" ~ func ~ ";" ~ "\n" ~
                            `static this() { ` ~ "\n" ~
                            `    mock_` ~ func ~ ` = ` ~ argNamesParens(T.length) ~ ` => ` ~ func ~
        argNamesParens(T.length) ~ ";\n" ~
                            "}\n" ~
                              "extern(C++) " ~ R.stringof ~ " ut_premock_" ~ func ~ typeAndArgsParens!T ~ " {\n" ~
                            "    return mock_" ~ func ~ argNamesParens(T.length) ~ ";\n" ~
                            "}";

}

string argNamesParens(int N) {
    return "(" ~ argNames(N) ~ ")";
}

string argNames(int N) {
    import std.range;
    import std.algorithm;
    return iota(N).map!(a => "arg" ~ a.to!string).join(", ");
}

string typeAndArgsParens(T...)() {
    import std.array;
    string[] parts;
    foreach(i, t; T)
        parts ~= T[i].stringof ~ " arg" ~ i.to!string;
    return "(" ~ parts.join(", ") ~ ")";
}
