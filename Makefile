JSONNET_FMT := jsonnetfmt -n 2 --max-blank-lines 2 --string-style s --comment-style s

.PHONY: fmt
fmt:
	find . -name 'examples/vendor' -prune -o -name '*.libsonnet' -print -o -name '*.jsonnet' -print | \
		xargs -n 1 -- $(JSONNET_FMT) -i

all: examples-http examples-grpc

examples-http: examples/http-request-errors-rules.json examples/http-request-errors-dashboard.json examples/http-request-latency-dashboard.json examples/http-request-latency-rules.json

examples/http-request-errors-rules.json: examples/http-request-errors-rules.jsonnet
	jsonnet -J examples/vendor examples/http-request-errors-rules.jsonnet > examples/http-request-errors-rules.json

examples/http-request-errors-dashboard.json: examples/http-request-errors-dashboard.jsonnet
	jsonnet -J examples/vendor examples/http-request-errors-dashboard.jsonnet > examples/http-request-errors-dashboard.json

examples/http-request-latency-dashboard.json: examples/http-request-latency-dashboard.jsonnet
	jsonnet -J examples/vendor examples/http-request-latency-dashboard.jsonnet > examples/http-request-latency-dashboard.json

examples/http-request-latency-rules.json: examples/http-request-latency-rules.jsonnet
	jsonnet -J examples/vendor examples/http-request-latency-rules.jsonnet > examples/http-request-latency-rules.json

examples-grpc: examples/grpc-request-errors-rules.json examples/grpc-request-errors-dashboard.json examples/grpc-request-latency-dashboard.json examples/grpc-request-latency-rules.json

examples/grpc-request-errors-rules.json: examples/grpc-request-errors-rules.jsonnet
	jsonnet -J examples/vendor examples/grpc-request-errors-rules.jsonnet > examples/grpc-request-errors-rules.json

examples/grpc-request-errors-dashboard.json: examples/grpc-request-errors-dashboard.jsonnet
	jsonnet -J examples/vendor examples/grpc-request-errors-dashboard.jsonnet > examples/grpc-request-errors-dashboard.json

examples/grpc-request-latency-dashboard.json: examples/grpc-request-latency-dashboard.jsonnet
	jsonnet -J examples/vendor examples/grpc-request-latency-dashboard.jsonnet > examples/grpc-request-latency-dashboard.json

examples/grpc-request-latency-rules.json: examples/grpc-request-latency-rules.jsonnet
	jsonnet -J examples/vendor examples/grpc-request-latency-rules.jsonnet > examples/grpc-request-latency-rules.json
