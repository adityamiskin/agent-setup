config-version: 8

server:
  host: "127.0.0.1"
  port: 8317

management:
  allow-remote: false
  secret-key: "__MANAGEMENT_KEY__"

access:
  api-keys:
    - "__ACCESS_KEY__"

oauth:
  auth-dir: "~/.cli-proxy-api"

routing:
  strategy: "weighted-round-robin"
  session-affinity: true
  session-affinity-ttl: "1h"
  retry:
    request-retry: 3
    max-retry-interval: 30

observability:
  logs:
    debug: false
    logging-to-file: false
    request-log: false
  usage:
    usage-statistics-enabled: false
