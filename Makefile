
IMG=devconf-conforma-demo

.PHONY: build
build:
	@docker build -t $(IMG) .

demo-%:
	@docker run -it $(IMG) $*

.PHONY: demo-all
demo-all: demo-1 demo-2 demo-3 demo-4

.PHONY: build-demo-all
build-run-all: build run-all

run-%:
	@cd demo$* && ./demo$*.sh

.PHONY: run-all
run-all: run-1 run-2 run-3 run-4
