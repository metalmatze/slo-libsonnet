all: examples

examples: examples/http-request-errors-rules.json examples/http-request-errors-dashboard.json examples/http-request-latency-dashboard.json examples/http-request-latency-rules.json

examples/http-request-errors-rules.json: examples/http-request-errors-rules.jsonnet
	jsonnet -J examples/vendor examples/http-request-errors-rules.jsonnet > examples/http-request-errors-rules.json

examples/http-request-errors-dashboard.json: examples/http-request-errors-dashboard.jsonnet
	jsonnet -J examples/vendor examples/http-request-errors-dashboard.jsonnet > examples/http-request-errors-dashboard.json

examples/http-request-latency-dashboard.json: examples/http-request-latency-dashboard.jsonnet
	jsonnet -J examples/vendor examples/http-request-latency-dashboard.jsonnet > examples/http-request-latency-dashboard.json

examples/http-request-latency-rules.json: examples/http-request-latency-rules.jsonnet
	jsonnet -J examples/vendor examples/http-request-latency-rules.jsonnet > examples/http-request-latency-rules.json
