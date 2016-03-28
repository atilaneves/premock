import premock;
import mocks;
import std.stdio;
import std.conv;
import std.typecons;
import core.exception;

extern(C) {
    long prod_send(int);
    int prod_zero();
    int prod_one(int i);
    int prod_two(int i, int j);
    void prod_three(double i, int j, const char* k);
}

extern(C++) int prod_twice(int i, int j);


void assertEqual(A, E)(A actual, E expected, in string file = __FILE__, in size_t line = __LINE__) {
    if(actual != expected) throw new Exception(text("\nExpected: ", expected,
                                                    "\nActual:   ", actual), file, line);
}

void main() {
    {
        auto _ = replace(mock_send, { return 7; });
        assertEqual(prod_send(0), 7);
    }

    // out of scope, send reverts to the "real" implementation
    // which will return -1 since 0 isn't a valid socket file
    // descriptor
    assertEqual(cast(int)prod_send(0), -1); //some weird cast is going on...

    {
        mixin mock!"send";
        prod_send(3);
        m.expectCalled().withValues(3, cast(const(void)*)null, 0UL, 0);
    }

    {
        immutable ret = 3;
        auto _ = replace(mock_other_zero, { return ret; });
        assertEqual(prod_zero(), ret);
    }

    {
        auto _ = replace(mock_other_one, (int i) { return 4 * i; });
        assertEqual(prod_one(8), 36);
    }
    {
        auto _ = replace(mock_other_two, (int i, int j) { return i + j + 1; });
        assertEqual(prod_two(3, 4), 8);
    }
    {
        auto _ = replace(mock_other_three, (double, int j, const char*) {
            assert(j != 2);
        });
        prod_three(0, 1, null);
        try {
            prod_three(0, 0, null); //should throw
            assert(0); //should never get here
        } catch(AssertError ex) { }
    }

    {
        mixin mock!"other_two";
        m.returnValue(5); //prod_two should call mock_other_two and return 5 no matter what
        assertEqual(prod_two(99, 999), 5);
        m.expectCalled().withValues(98, 1000);
    }

    {
        mixin mock!"other_two";
        m.returnValue(11, 22, 33);
        assertEqual(prod_two(99, 999), 11);
        assertEqual(prod_two(9, 10), 22);
        assertEqual(prod_two(5, 5), 33);
        m.expectCalled(3).withValues(4, 6);
    }

    {
        mixin mock!("other_one", "mock1"); //because we can
        mixin mock!("other_two", "mock2");
        mock2.returnValue(11, 22, 33);
        assertEqual(prod_two(99, 999), 11);
        assertEqual(prod_two(9, 10), 22);
        assertEqual(prod_two(5, 5), 33);
        mock2.expectCalled(3).withValues(tuple(98, 1000), tuple(8, 11), tuple(4, 6));
    }

    {
        //C++ function mocking
        mixin mock!"twice";
        prod_twice(2, 3);
        m.expectCalled().withValues(5);
    }


    writeln("Ok D   Example");
}
