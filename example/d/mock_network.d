module mock_network;

import premock;

mixin ImplCMock!("send", long, int, const(void)*, size_t, int);
