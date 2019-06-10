all: examples

examples: examples/http-request-errors.json examples/http-request-latency-dashboard.json examples/http-request-latency.json

examples/http-request-errors.json: examples/http-request-errors.jsonnet
	jsonnet -J examples/vendor examples/http-request-errors.jsonnet > examples/http-request-errors.json

examples/http-request-latency-dashboard.json: examples/http-request-latency-dashboard.jsonnet
	jsonnet -J examples/vendor examples/http-request-latency-dashboard.jsonnet > examples/http-request-latency-dashboard.json

examples/http-request-latency.json: examples/http-request-latency.jsonnet
	jsonnet -J examples/vendor examples/http-request-latency.jsonnet > examples/http-request-latency.json
