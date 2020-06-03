
.PHONY: build-in-docker jsonnetfmt examples/http-request-latency-burnrate.yaml examples/http-request-error-burnrate.yaml examples/http-request-errors.yaml examples/http-request-latency.yaml

JSONNET_SRC = $(shell find . -type f -not -path './*vendor/*' \( -name '*.libsonnet' -o -name '*.jsonnet' \))

all: examples jsonnetfmt

jsonnetfmt: $(JSONNET_SRC)
	jsonnetfmt -n 2 --max-blank-lines 2 --string-style s --comment-style s -i $(JSONNET_SRC)

examples: examples/http-request-latency-burnrate.yaml examples/http-request-error-burnrate.yaml examples/http-request-errors.yaml examples/http-request-latency.yaml

examples/http-request-error-burnrate.yaml: examples/http-request-error-burnrate.jsonnet
	jsonnet -J examples/vendor examples/http-request-error-burnrate.jsonnet | gojsontoyaml > examples/http-request-error-burnrate.yaml

examples/http-request-errors.yaml: examples/http-request-errors.jsonnet
	jsonnet -J examples/vendor examples/http-request-errors.jsonnet | gojsontoyaml > examples/http-request-errors.yaml

examples/http-request-latency-burnrate.yaml: examples/http-request-latency-burnrate.jsonnet
	jsonnet -J examples/vendor examples/http-request-latency-burnrate.jsonnet | gojsontoyaml > examples/http-request-latency-burnrate.yaml

examples/http-request-latency.yaml: examples/http-request-latency.jsonnet
	jsonnet -J examples/vendor examples/http-request-latency.jsonnet | gojsontoyaml > examples/http-request-latency.yaml

build-in-docker: 
	docker run --rm -v $(PWD):/slo quay.io/coreos/jsonnet-ci bash -c "cd /slo/examples && jb install && cd .. && make"