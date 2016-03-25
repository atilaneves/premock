import std.stdio;

extern(C) long send(int, const void*, size_t, int);

void main() {
    auto m = mockScope!(send)
}
