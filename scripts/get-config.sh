#!/bin/bash
set -euo pipefail

VERSION="${1:-v1.14.1}"

download() {
  curl -fsSL \
    "https://raw.githubusercontent.com/firecracker-microvm/firecracker/${VERSION}/resources/guest_configs/microvm-kernel-ci-${1}-6.1.config" \
    --output-dir configs -O
}

main() {
  for arch in x86_64 aarch64; do
    download "${arch}"
  done
}

main
