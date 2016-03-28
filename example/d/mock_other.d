module mock_other;

import premock;

mixin ImplCMock!("other_zero", int);
mixin ImplCMock!("other_one", int, int);
mixin ImplCMock!("other_two", int, int, int);
mixin ImplCMock!("other_three", void, double, int, const char*);
mixin(implCppMockStr!("twice", int, int)); //ImplMock doesn't work because of mangling
