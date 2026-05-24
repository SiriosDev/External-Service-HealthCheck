FROM alpine:latest

# (opzionale) strumenti base
RUN apk add --no-cache bash docker-cli docker-compose

COPY healthcheck.sh /healthcheck.sh
RUN chmod +x /healthcheck.sh

HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
  CMD /healthcheck.sh

# comando che mantiene il container vivo
CMD ["sh", "-c", "tail -f /dev/null"]
