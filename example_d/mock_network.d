module mock_network;

import premock;

mixin ImplMock!("send", long, int, const void*, size_t, int); //doesn't work because it mangles
mixin(implMockStr!("send", long, int, const void*, size_t, int));
