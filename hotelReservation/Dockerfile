FROM golang:1.17

COPY . $GOPATH/src/github.com/harlow/go-micro-services
WORKDIR $GOPATH/src/github.com/harlow/go-micro-services
# Omit symbol table, debug information and DWARF table with '-s -w' flag
RUN go install -ldflags="-s -w" ./cmd/...
