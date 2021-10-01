FROM golang:1.17

COPY . /go/src/github.com/harlow/go-micro-services
WORKDIR /go/src/github.com/harlow/go-micro-services
RUN go get gopkg.in/mgo.v2
RUN go get github.com/bradfitz/gomemcache/memcache
RUN go get github.com/google/uuid
RUN go get github.com/prometheus/client_golang/prometheus
RUN go get github.com/prometheus/client_golang/prometheus/promauto
RUN go get github.com/prometheus/client_golang/prometheus/promhttp
RUN go install -ldflags="-s -w" ./cmd/...
