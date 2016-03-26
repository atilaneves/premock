module mock_other;

import premock;

mixin(implMockStr!("C", "other_zero", int));
mixin(implMockStr!("C", "other_one", int, int));
mixin(implMockStr!("C", "other_two", int, int, int));
mixin(implMockStr!("C", "other_three", void, int, const char*));
mixin(implMockStr!("C++", "twice", int, int));
