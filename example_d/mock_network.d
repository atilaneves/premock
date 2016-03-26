module mock_network;


long delegate(int, const void*, size_t, int) mock_send;
extern(C) long ut_send(int arg0, const void* arg1, size_t arg2, int arg3) {
    return mock_send(arg0, arg1, arg2, arg3);
}
