module mock_network;

import premock;

mixin ImplCMockDefault!("send", long, int, const(void)*, size_t, int);
