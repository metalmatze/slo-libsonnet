all: examples

examples: examples/http-request-errorburnrate.yaml examples/http-request-errors.yaml examples/http-request-latency.yaml

examples/http-request-errorburnrate.yaml: examples/http-request-errorburnrate.jsonnet
	jsonnet -J examples/vendor examples/http-request-errorburnrate.jsonnet | gojsontoyaml > examples/http-request-errorburnrate.yaml

examples/http-request-errors.yaml: examples/http-request-errors.jsonnet
	jsonnet -J examples/vendor examples/http-request-errors.jsonnet | gojsontoyaml > examples/http-request-errors.yaml

examples/http-request-latency.yaml: examples/http-request-latency.jsonnet
	jsonnet -J examples/vendor examples/http-request-latency.jsonnet | gojsontoyaml > examples/http-request-latency.yaml
