#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

if [ ! -f "fedora-41-base.qcow2" ]; then
    wget -q \
        https://download.fedoraproject.org/pub/fedora/linux/releases/41/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-41-1.4.x86_64.qcow2 \
        -O fedora-41-base.qcow2
fi

cloud-localds cloud-init.img cloud-init.yaml

if [ ! -f "fedora-working-layer.qcow2" ]; then
    qemu-img create -f qcow2 -b fedora-41-base.qcow2 -F qcow2 fedora-working-layer.qcow2
fi

qemu-system-x86_64 \
    -m 8G \
    -smp 4 \
    -enable-kvm \
    -drive file=fedora-working-layer.qcow2,format=qcow2 \
    -device virtio-vga-gl \
    -display gtk,gl=on \
    -nic user,hostfwd=tcp::2222-:22 \
    -drive file=cloud-init.img,format=raw
