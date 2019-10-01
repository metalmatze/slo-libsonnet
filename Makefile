all: examples

examples: examples/http-request-errorburnrate.json examples/http-request-errors-rules.json examples/http-request-errors-dashboard.json examples/http-request-latency-dashboard.json examples/http-request-latency-rules.json

examples/http-request-errorburnrate.json: examples/http-request-errorburnrate.jsonnet
	jsonnet -J examples/vendor examples/http-request-errorburnrate.jsonnet > examples/http-request-errorburnrate.json

examples/http-request-errors.yaml: examples/http-request-errors.jsonnet
	jsonnet -J examples/vendor examples/http-request-errors.jsonnet | gojsontoyaml > examples/http-request-errors.yaml

examples/http-request-latency.yaml: examples/http-request-latency.jsonnet
	jsonnet -J examples/vendor examples/http-request-latency.jsonnet | gojsontoyaml > examples/http-request-latency.yaml
