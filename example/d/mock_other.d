module mock_other;

import premock;

mixin ImplCMockDefault!("other_zero", int);
mixin ImplCMockDefault!("other_one", int, int);
mixin ImplCMockDefault!("other_two", int, int, int);
mixin ImplCMockDefault!("other_three", void, double, int, const char*);
mixin(implCppMockStr!("twice", int, int)); //ImplMock doesn't work because of mangling
