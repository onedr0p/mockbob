FROM golang:1.18.5-alpine as builder
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT=""
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=${TARGETOS} \
    GOARCH=${TARGETARCH} \
    GOARM=${TARGETVARIANT}
RUN apk add --no-cache tini-static
WORKDIR /build
COPY . .
RUN go build -a -tags netgo -ldflags '-w -extldflags "-static"' -o mockbob /build/cmd/.

FROM gcr.io/distroless/static:nonroot
USER nonroot:nonroot
COPY --from=builder --chown=nonroot:nonroot /build/mockbob /mockbob
COPY --from=builder --chown=nonroot:nonroot /sbin/tini-static /tini
ENTRYPOINT [ "/tini", "--", "/mockbob" ]
LABEL \
    org.opencontainers.image.title="mockbob" \
    org.opencontainers.image.source="https://github.com/onedr0p/mockbob"
