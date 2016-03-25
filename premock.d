module premock;

void replace(string func, alias lambda)() {

}

version(unittest) {
    int delegate(int) mock_twice;

    static this() {
        mock_twice = (i) => i * 2;
    }
}

@("replace works correctly")
unittest {
    {
        replace!("twice", (i) { return i * 3; });
        assert(mock_twice(3) == 9);
    }
    assert(mock_twice(3) == 6); //should return to default implementation
}
