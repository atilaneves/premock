module mock_other;

extern(C) {
    int ut_other_zero() {
        return 0;
    }

    int ut_other_one(int) {
        return 0;
    }

    int ut_other_two(int, int) {
        return 0;
    }

    void ut_other_three(double, int, const char*) {

    }
}

extern(C++) int ut_twice(int) {
    return 0;
}
