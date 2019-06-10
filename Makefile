all: examples

examples: examples/http-request-errors.json examples/http-request-latency.json

examples/http-request-errors.json: examples/http-request-errors.jsonnet
	jsonnet examples/http-request-errors.jsonnet > examples/http-request-errors.json

examples/http-request-latency.json: examples/http-request-latency.jsonnet
	jsonnet examples/http-request-latency.jsonnet > examples/http-request-latency.json
