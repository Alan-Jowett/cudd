all: test

configure:
	@cmake -S . -B /tmp/build . -DCUDD_BUILD_TESTS=ON

build: configure
	@cmake --build /tmp/build 

test: build
	@ctest --test-dir /tmp/build --output-on-failure

clean:
	@rm -rf /tmp/build
