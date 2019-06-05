all: examples

examples: examples/http-request-latency.json

examples/http-request-latency.json: examples/http-request-latency.jsonnet
	jsonnet examples/http-request-latency.jsonnet > examples/http-request-latency.json
