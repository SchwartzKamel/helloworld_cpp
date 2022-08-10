
build:
	docker build -t sierrahackingco/helloworld_cpp:latest .

test:
	docker run --name helloworld_cpp sierrahackingco/helloworld_cpp:latest

help:
	@echo "build test"

