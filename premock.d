module premock;


import std.traits;
import std.typecons;
import std.conv;
import std.exception;
import std.meta;

version(unittest) {
    import core.exception;
}

struct MockScope(T) if(isDelegate!T) {

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

private U toDelegate(U, T)(T f) {
    static if(!isDelegate!T) {
        int i; //just so it's captured
        mixin(q{ return cast(U) } ~ typeAndArgsParens!(Parameters!T) ~ "{\n" ~
              q{ ++i; } ~
              "return f" ~ argNamesParens(Parameters!T.length) ~ ";\n" ~
              "};");

    } else
        return cast(U)f;
}

string mockName(in string func) {
    return "mock_" ~ func;
}

alias mockType(string func) = typeof(mixin(mockName(func)));

auto replace(string func)(mockType!func newFunc) {
    mixin("alias mock_func = " ~ mockName(func) ~ ";");
    return MockScope!(mockType!func)(mock_func, newFunc);
}

mixin template replace2(string func, string newFunc, string varName = "_") {

    mixin("auto " ~ varName ~ q{ = MockScope!(mockType!func)(} ~ mockName(func) ~ ", " ~ "(int i){return i * 3; }" ~ ");");
}

version(unittest) {
    int delegate(int) mock_twice_ut;

    static this() {
        mock_twice_ut = (i) => i * 2;
    }
}

@("replace works correctly")
unittest {
    import std.conv;
    {
        mixin replace2!("twice_ut", q{ i => i * 3 });
        //auto _ = replace!("twice_ut")(i => i * 3);
        assert(mock_twice_ut(3) == 9);
    }

    assert(mock_twice_ut(3) == 6); //should return to default implementation
}


class MockException: Exception {
    this(string msg, string file = __FILE__, ulong line = cast(ulong)__LINE__, Throwable next = null) {
        super(msg, file, line, next);
    }
}

struct Mock(T) {
    this(ref T func) {
        import std.array;

        _returns = [ReturnType!T.init];

        ReturnType!T inner(Parameters!T values) {
            _values ~= tuple(values);

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

private:

    MockScope!T _scope;
    ReturnType!T[] _returns;
    Tuple!(Parameters!T)[] _values;

    static string capitalize(int val, string word) {
        return val == 1 ? "1 " ~ word : val.to!string ~ " " ~ word ~ "s";
    }

    static void throwValueException(U, V)(U expected, V actual) {
         throw new MockException(text("Invocation values do not match\n",
                                      "Expected: ", expected, "\n",
                                      "Actual:   ", actual, "\n"));

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


mixin template ImplMock(string func, R, T...) {
    mixin(q{ extern(C) R } ~ func ~ q{ (T); });
}

string implMockStr(string lang, string func, R, T...)() {
    return "extern(" ~ lang ~ ")" ~ R.stringof ~ " " ~ func ~ T.stringof ~ ";" ~ "\n" ~
                            R.stringof ~ " delegate" ~ T.stringof ~ " mock_" ~ func ~ ";" ~ "\n" ~
                            `static this() { ` ~ "\n" ~
                            `    mock_` ~ func ~ ` = ` ~ argNamesParens(T.length) ~ ` => ` ~ func ~ argNamesParens(T.length) ~ ";\n" ~
                            "}\n" ~
                              "extern(" ~ lang ~ ") " ~ R.stringof ~ " ut_" ~ func ~ typeAndArgsParens!T ~ " {\n" ~
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
