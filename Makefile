all: examples

examples: examples/http-request-latency-burnrate.yaml examples/http-request-error-burnrate.yaml examples/http-request-errors.yaml examples/http-request-latency.yaml

examples/http-request-error-burnrate.yaml: examples/http-request-error-burnrate.jsonnet
	jsonnet -J examples/vendor examples/http-request-error-burnrate.jsonnet | gojsontoyaml > examples/http-request-error-burnrate.yaml

examples/http-request-errors.yaml: examples/http-request-errors.jsonnet
	jsonnet -J examples/vendor examples/http-request-errors.jsonnet | gojsontoyaml > examples/http-request-errors.yaml

examples/http-request-latency-burnrate.yaml: examples/http-request-latency-burnrate.jsonnet
	jsonnet -J examples/vendor examples/http-request-latency-burnrate.jsonnet | gojsontoyaml > examples/http-request-latency-burnrate.yaml

examples/http-request-latency.yaml: examples/http-request-latency.jsonnet
	jsonnet -J examples/vendor examples/http-request-latency.jsonnet | gojsontoyaml > examples/http-request-latency.yaml
