import premock;
import mock_network;
import std.stdio;
import std.conv;

//extern(C) long send(int, const void*, size_t, int);
extern(C) long prod_send(int);

// void assertEqual(A, E)(A actual, E expected, in string file = __FILE__, in ulong line = cast(ulong)__LINE__) {
//     if(actual != expected) throw new Exception(("\nExpected: ", expected,
//                                                 "\nActual:   ", actual), file, line);
// }

void main() {
    {
        //auto _ = replace!("send")({ return 7; });// (int, const void*, size_t, int) { return 7; });
        //typeof(mock_send) repl = cast(typeof(mock_send)){ return 7; };
        typeof(mock_send) repl = delegate(int, const void*, size_t, int) { return 7; };
        auto _ = MockScope!(typeof(mock_send))(mock_send, repl);
        //auto _ = MockScope!(typeof(mock_send))(mock_send, delegate(int, const void*, size_t, int) { return 7; });
        //assertEqual(prod_send(0), 7);
        assert(prod_send(0) == 7);
    }

    // out of scope, send reverts to the "real" implementation
    // which will return -1 since 0 isn't a valid socket file
    // descriptor
    //assertEqual(prod_send(0), -1);

    writeln("Ok D");
}
