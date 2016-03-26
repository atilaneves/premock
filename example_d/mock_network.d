module mock_network;


extern(C) long send(int arg0, const void* arg1, size_t arg2, int arg3);
long delegate(int, const void*, size_t, int) mock_send;
static this() {
    mock_send = (arg0, arg1, arg2, arg3) => send(arg0, arg1, arg2, arg3);
}
extern(C) long ut_send(int arg0, const void* arg1, size_t arg2, int arg3) {
    return mock_send(arg0, arg1, arg2, arg3);
}
