#############################
# Multi-Stage Build

FROM golang:stretch as builder

RUN mkdir -p /go/src/github.com/cloudflare && \
    cd /go/src/github.com/cloudflare && \
    git clone https://github.com/cloudflare/alertmanager2es.git

# Build Statically-Linked Binary
RUN cd /go/src/github.com/cloudflare/alertmanager2es && \
  GOOS=linux GOARCH=amd64 CGO_ENABLED=0 go build \
    -ldflags "-w -extldflags \"-static\" \
    -X main.revision=$(git describe --tags --always --dirty=-dev)"

#############################
# Final-Stage Build

FROM alpine:latest

COPY --from=builder /go/src/github.com/cloudflare/alertmanager2es/alertmanager2es \
     /bin/alertmanager2es

EXPOSE 9097
ENTRYPOINT [ "/bin/alertmanager2es" ]
