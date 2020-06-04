all: examples

examples: examples/vendor examples/http-request-latency-burnrate.yaml examples/http-request-error-burnrate.yaml examples/http-request-errors.yaml examples/http-request-latency.yaml

examples/vendor: examples/jsonnetfile.json examples/jsonnetfile.lock.json .bingo/jb
	cd examples && ../.bingo/jb install

examples/http-request-error-burnrate.yaml: examples/http-request-error-burnrate.jsonnet .bingo/jsonnetfmt .bingo/jsonnet .bingo/gojsontoyaml
	.bingo/jsonnetfmt -i examples/http-request-error-burnrate.jsonnet
	.bingo/jsonnet -J examples/vendor examples/http-request-error-burnrate.jsonnet | .bingo/gojsontoyaml > examples/http-request-error-burnrate.yaml

examples/http-request-errors.yaml: examples/http-request-errors.jsonnet .bingo/jsonnetfmt .bingo/jsonnet .bingo/gojsontoyaml
	.bingo/jsonnetfmt -i examples/http-request-errors.jsonnet
	.bingo/jsonnet -J examples/vendor examples/http-request-errors.jsonnet | .bingo/gojsontoyaml > examples/http-request-errors.yaml

examples/http-request-latency-burnrate.yaml: examples/http-request-latency-burnrate.jsonnet .bingo/jsonnetfmt .bingo/jsonnet .bingo/gojsontoyaml
	.bingo/jsonnetfmt -i examples/http-request-latency-burnrate.jsonnet
	.bingo/jsonnet -J examples/vendor examples/http-request-latency-burnrate.jsonnet | .bingo/gojsontoyaml > examples/http-request-latency-burnrate.yaml

examples/http-request-latency.yaml: examples/http-request-latency.jsonnet .bingo/jsonnetfmt .bingo/jsonnet .bingo/gojsontoyaml
	.bingo/jsonnetfmt -i examples/http-request-latency.jsonnet
	.bingo/jsonnet -J examples/vendor examples/http-request-latency.jsonnet | .bingo/gojsontoyaml > examples/http-request-latency.yaml

.bingo/jb:
	go build -modfile .bingo/jb.mod -o .bingo/jb github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb

.bingo/jsonnet:
	go build -modfile .bingo/jsonnet.mod -o .bingo/jsonnet github.com/google/go-jsonnet/cmd/jsonnet

.bingo/jsonnetfmt:
	go build -modfile .bingo/jsonnetfmt.mod -o .bingo/jsonnetfmt github.com/google/go-jsonnet/cmd/jsonnetfmt

.bingo/gojsontoyaml:
	go build -modfile .bingo/gojsontoyaml.mod -o .bingo/gojsontoyaml github.com/brancz/gojsontoyaml
