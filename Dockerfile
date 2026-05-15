FROM golang:1.22-alpine AS builder

WORKDIR /app

COPY iim-sdk/ /iim-sdk/
COPY iim-server/go.mod iim-server/go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o iim-server main.go

FROM alpine:latest

RUN apk --no-cache add tzdata

WORKDIR /app

COPY --from=builder /app/iim-server .
COPY --from=builder /app/manifest ./manifest
COPY --from=builder /app/log ./log
COPY --from=builder /app/resource ./resource

RUN mkdir -p /app/log

EXPOSE 8000

CMD ["./iim-server"]