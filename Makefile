# Automatically generated by reggae version 0.5.2+
# Do not edit by hand
all: example_test ut
.SUFFIXES:
CC = clang
CXX = clang++
DC = dmd
objs/example_test.objs/example/test/mock_network.o: /home/atila/coding/cpp/premock/example/test/mock_network.cpp Makefile
	$(CC)++ -Wall -Werror -Wextra -g -std=c++14 -I/home/atila/coding/cpp/premock/. -I/home/atila/coding/cpp/premock/example/test -I/home/atila/coding/cpp/premock/example/src -I/home/atila/coding/cpp/premock/example/deps -MMD -MT objs/example_test.objs/example/test/mock_network.o -MF objs/example_test.objs/example/test/mock_network.o.dep -o objs/example_test.objs/example/test/mock_network.o -c /home/atila/coding/cpp/premock/example/test/mock_network.cpp
	@cp objs/example_test.objs/example/test/mock_network.o.dep objs/example_test.objs/example/test/mock_network.o.dep.P; \
    sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\$$//' \
        -e '/^$$/ d' -e 's/$$/ :/' < objs/example_test.objs/example/test/mock_network.o.dep >> objs/example_test.objs/example/test/mock_network.o.dep.P; \
    rm -f objs/example_test.objs/example/test/mock_network.o.dep

-include objs/example_test.objs/example/test/mock_network.o.dep.P


objs/example_test.objs/example/test/mock_other.o: /home/atila/coding/cpp/premock/example/test/mock_other.cpp Makefile
	$(CC)++ -Wall -Werror -Wextra -g -std=c++14 -I/home/atila/coding/cpp/premock/. -I/home/atila/coding/cpp/premock/example/test -I/home/atila/coding/cpp/premock/example/src -I/home/atila/coding/cpp/premock/example/deps -MMD -MT objs/example_test.objs/example/test/mock_other.o -MF objs/example_test.objs/example/test/mock_other.o.dep -o objs/example_test.objs/example/test/mock_other.o -c /home/atila/coding/cpp/premock/example/test/mock_other.cpp
	@cp objs/example_test.objs/example/test/mock_other.o.dep objs/example_test.objs/example/test/mock_other.o.dep.P; \
    sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\$$//' \
        -e '/^$$/ d' -e 's/$$/ :/' < objs/example_test.objs/example/test/mock_other.o.dep >> objs/example_test.objs/example/test/mock_other.o.dep.P; \
    rm -f objs/example_test.objs/example/test/mock_other.o.dep

-include objs/example_test.objs/example/test/mock_other.o.dep.P


objs/example_test.objs/example/test/test.o: /home/atila/coding/cpp/premock/example/test/test.cpp Makefile
	$(CC)++ -Wall -Werror -Wextra -g -std=c++14 -I/home/atila/coding/cpp/premock/. -I/home/atila/coding/cpp/premock/example/test -I/home/atila/coding/cpp/premock/example/src -I/home/atila/coding/cpp/premock/example/deps -MMD -MT objs/example_test.objs/example/test/test.o -MF objs/example_test.objs/example/test/test.o.dep -o objs/example_test.objs/example/test/test.o -c /home/atila/coding/cpp/premock/example/test/test.cpp
	@cp objs/example_test.objs/example/test/test.o.dep objs/example_test.objs/example/test/test.o.dep.P; \
    sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\$$//' \
        -e '/^$$/ d' -e 's/$$/ :/' < objs/example_test.objs/example/test/test.o.dep >> objs/example_test.objs/example/test/test.o.dep.P; \
    rm -f objs/example_test.objs/example/test/test.o.dep

-include objs/example_test.objs/example/test/test.o.dep.P


objs/example_test.objs/example/src/prod.o: /home/atila/coding/cpp/premock/example/src/prod.c Makefile
	$(CC) -Wall -Werror -Wextra -g -DPREMOCK_ENABLE -include mocks.h -I/home/atila/coding/cpp/premock/. -I/home/atila/coding/cpp/premock/example/test -I/home/atila/coding/cpp/premock/example/src -I/home/atila/coding/cpp/premock/example/deps -MMD -MT objs/example_test.objs/example/src/prod.o -MF objs/example_test.objs/example/src/prod.o.dep -o objs/example_test.objs/example/src/prod.o -c /home/atila/coding/cpp/premock/example/src/prod.c
	@cp objs/example_test.objs/example/src/prod.o.dep objs/example_test.objs/example/src/prod.o.dep.P; \
    sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\$$//' \
        -e '/^$$/ d' -e 's/$$/ :/' < objs/example_test.objs/example/src/prod.o.dep >> objs/example_test.objs/example/src/prod.o.dep.P; \
    rm -f objs/example_test.objs/example/src/prod.o.dep

-include objs/example_test.objs/example/src/prod.o.dep.P


objs/example_test.objs/example/deps/other.o: /home/atila/coding/cpp/premock/example/deps/other.c Makefile
	$(CC) -Wall -Werror -Wextra -g  -MMD -MT objs/example_test.objs/example/deps/other.o -MF objs/example_test.objs/example/deps/other.o.dep -o objs/example_test.objs/example/deps/other.o -c /home/atila/coding/cpp/premock/example/deps/other.c
	@cp objs/example_test.objs/example/deps/other.o.dep objs/example_test.objs/example/deps/other.o.dep.P; \
    sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\$$//' \
        -e '/^$$/ d' -e 's/$$/ :/' < objs/example_test.objs/example/deps/other.o.dep >> objs/example_test.objs/example/deps/other.o.dep.P; \
    rm -f objs/example_test.objs/example/deps/other.o.dep

-include objs/example_test.objs/example/deps/other.o.dep.P


example_test: objs/example_test.objs/example/test/mock_network.o objs/example_test.objs/example/test/mock_other.o objs/example_test.objs/example/test/test.o objs/example_test.objs/example/src/prod.o objs/example_test.objs/example/deps/other.o Makefile
	$(CC)++ -o example_test  objs/example_test.objs/example/test/mock_network.o objs/example_test.objs/example/test/mock_other.o objs/example_test.objs/example/test/test.o objs/example_test.objs/example/src/prod.o objs/example_test.objs/example/deps/other.o
objs/ut.objs/tests/main.o: /home/atila/coding/cpp/premock/tests/main.cpp Makefile
	$(CC)++ -Wall -Werror -Wextra -g -std=c++14 -I/home/atila/coding/cpp/premock/. -I/home/atila/coding/cpp/premock/tests -MMD -MT objs/ut.objs/tests/main.o -MF objs/ut.objs/tests/main.o.dep -o objs/ut.objs/tests/main.o -c /home/atila/coding/cpp/premock/tests/main.cpp
	@cp objs/ut.objs/tests/main.o.dep objs/ut.objs/tests/main.o.dep.P; \
    sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\$$//' \
        -e '/^$$/ d' -e 's/$$/ :/' < objs/ut.objs/tests/main.o.dep >> objs/ut.objs/tests/main.o.dep.P; \
    rm -f objs/ut.objs/tests/main.o.dep

-include objs/ut.objs/tests/main.o.dep.P


objs/ut.objs/tests/test_mock_scope.o: /home/atila/coding/cpp/premock/tests/test_mock_scope.cpp Makefile
	$(CC)++ -Wall -Werror -Wextra -g -std=c++14 -I/home/atila/coding/cpp/premock/. -I/home/atila/coding/cpp/premock/tests -MMD -MT objs/ut.objs/tests/test_mock_scope.o -MF objs/ut.objs/tests/test_mock_scope.o.dep -o objs/ut.objs/tests/test_mock_scope.o -c /home/atila/coding/cpp/premock/tests/test_mock_scope.cpp
	@cp objs/ut.objs/tests/test_mock_scope.o.dep objs/ut.objs/tests/test_mock_scope.o.dep.P; \
    sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\$$//' \
        -e '/^$$/ d' -e 's/$$/ :/' < objs/ut.objs/tests/test_mock_scope.o.dep >> objs/ut.objs/tests/test_mock_scope.o.dep.P; \
    rm -f objs/ut.objs/tests/test_mock_scope.o.dep

-include objs/ut.objs/tests/test_mock_scope.o.dep.P


objs/ut.objs/tests/test_traits.o: /home/atila/coding/cpp/premock/tests/test_traits.cpp Makefile
	$(CC)++ -Wall -Werror -Wextra -g -std=c++14 -I/home/atila/coding/cpp/premock/. -I/home/atila/coding/cpp/premock/tests -MMD -MT objs/ut.objs/tests/test_traits.o -MF objs/ut.objs/tests/test_traits.o.dep -o objs/ut.objs/tests/test_traits.o -c /home/atila/coding/cpp/premock/tests/test_traits.cpp
	@cp objs/ut.objs/tests/test_traits.o.dep objs/ut.objs/tests/test_traits.o.dep.P; \
    sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\$$//' \
        -e '/^$$/ d' -e 's/$$/ :/' < objs/ut.objs/tests/test_traits.o.dep >> objs/ut.objs/tests/test_traits.o.dep.P; \
    rm -f objs/ut.objs/tests/test_traits.o.dep

-include objs/ut.objs/tests/test_traits.o.dep.P


objs/ut.objs/tests/test_exceptions.o: /home/atila/coding/cpp/premock/tests/test_exceptions.cpp Makefile
	$(CC)++ -Wall -Werror -Wextra -g -std=c++14 -I/home/atila/coding/cpp/premock/. -I/home/atila/coding/cpp/premock/tests -MMD -MT objs/ut.objs/tests/test_exceptions.o -MF objs/ut.objs/tests/test_exceptions.o.dep -o objs/ut.objs/tests/test_exceptions.o -c /home/atila/coding/cpp/premock/tests/test_exceptions.cpp
	@cp objs/ut.objs/tests/test_exceptions.o.dep objs/ut.objs/tests/test_exceptions.o.dep.P; \
    sed -e 's/#.*//' -e 's/^[^:]*: *//' -e 's/ *\$$//' \
        -e '/^$$/ d' -e 's/$$/ :/' < objs/ut.objs/tests/test_exceptions.o.dep >> objs/ut.objs/tests/test_exceptions.o.dep.P; \
    rm -f objs/ut.objs/tests/test_exceptions.o.dep

-include objs/ut.objs/tests/test_exceptions.o.dep.P


ut: objs/ut.objs/tests/main.o objs/ut.objs/tests/test_mock_scope.o objs/ut.objs/tests/test_traits.o objs/ut.objs/tests/test_exceptions.o Makefile
	$(CC)++ -o ut  objs/ut.objs/tests/main.o objs/ut.objs/tests/test_mock_scope.o objs/ut.objs/tests/test_traits.o objs/ut.objs/tests/test_exceptions.o