#!/bin/bash
set -euo pipefail

VERSION="${VERSION:-6.1.102}"
ARCH="${ARCH:-x86_64}"

arch() {
  case "${ARCH}" in
    x86_64)  echo "x86" ;;
    aarch64) echo "arm64" ;;
  esac
}

cross_compile() {
  case "${ARCH}" in
    aarch64) echo "aarch64-linux-gnu-" ;;
    *)       echo "" ;;
  esac
}

image() {
  case "${ARCH}" in
    x86_64)  echo "vmlinux" ;;
    aarch64) echo "arch/arm64/boot/Image" ;;
  esac
}

download() {
  curl -fsSL "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${VERSION}.tar.xz" | tar -xJf -
}

build() {
  cd "linux-${VERSION}"
  scripts/kconfig/merge_config.sh -m \
    "../configs/microvm-kernel-ci-${ARCH}-6.1.config" \
    "../configs/overlay.config"
  make ARCH="$(arch)" CROSS_COMPILE="$(cross_compile)" olddefconfig
  make ARCH="$(arch)" CROSS_COMPILE="$(cross_compile)" -j"$(nproc)" "$(basename "$(image)")"
}

copy() {
  mkdir -p "../build"
  cp "$(image)" .config "../build/"
}

main() {
  download
  build
  copy
}

main
