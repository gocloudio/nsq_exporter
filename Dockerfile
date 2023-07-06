# syntax=docker/dockerfile:1.4
ARG NAME=nsq_exporter

FROM --platform=$BUILDPLATFORM golang:1.20.5-alpine3.18 as builder
ARG NAME
WORKDIR /app
COPY . /app
ARG TARGETOS
ARG TARGETARCH
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg CGO_ENABLED=0 \
    GOOS=$TARGETOS GOARCH=$TARGETARCH go build -o /go/${NAME} .

FROM alpine:3.18
ARG NAME
ENV NAME=${NAME}
WORKDIR /app
COPY --from=builder /go/${NAME} /app/${NAME}
CMD /app/${NAME}
EXPOSE 9117
ENTRYPOINT ["/app/nsq_exporter"]
