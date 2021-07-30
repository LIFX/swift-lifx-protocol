test:
	swift test --package-path ./ --parallel --enable-test-discovery
clean:
	rm -rf .swiftpm DerivedData .build