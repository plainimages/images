#!/usr/bin/env bash
# Starts the image in SpiceDB testing mode and waits until the gRPC health check passes.
# Usage: scripts/smoke-test.sh IMAGE [TIMEOUT_SECONDS]
set -euo pipefail

image="${1:?usage: $0 IMAGE [TIMEOUT_SECONDS]}"
timeout="${2:-30}"

# No --rm: if SpiceDB crashes we still want its logs. The trap cleans up.
cid=$(docker run -d "$image" temporal serve-dev --skip-release-check)
trap 'docker rm -f "$cid" >/dev/null 2>&1 || true' EXIT

for _ in $(seq 1 "$timeout"); do
  if docker exec "$cid" /bin/grpc_health_probe -addr=localhost:50051 >/dev/null 2>&1; then
    echo "OK: $image is healthy"
    exit 0
  fi
  if [ "$(docker inspect -f '{{.State.Running}}' "$cid")" != "true" ]; then
    echo "FAIL: container exited early" >&2
    break
  fi
  sleep 1
done

echo "FAIL: $image not healthy after ${timeout}s" >&2
docker logs "$cid" >&2 || true
exit 1
