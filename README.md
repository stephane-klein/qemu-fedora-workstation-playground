# Qemu Fedora Workstation playground

This playground allows testing the launch of a Fedora Workstation OS - the Desktop version - in Qemu.
My initial goal with this playground is to be able to automatically test the installation of my workstation with Chezmoi in the future.

My second goal with this playground is to explore a minimalist alternative to Vagrant.

This playground is meant to be run and has been tested on Fedora 41.

## Getting started

Install required packages:

```
$ sudo dnf install -y \
    qemu-system-x86 \
    qemu-system-common \
    qemu-img \
    qemu-img-extras \
    cloud-utils \
    mesa-dri-drivers \
    libguestfs-tools
```

> [!TIP]
> From here, you can use `./scripts/up.sh` to execute all commands up to "step 3"

Download Fedora 41 "cloud" version image:

```sh
$ wget https://download.fedoraproject.org/pub/fedora/linux/releases/41/Cloud/x86_64/images/Fedora-Cloud-Base-Generic-41-1.4.x86_64.qcow2 -O fedora-41-base.qcow2
```

Prepare CloudInit file to configure default user password:

```sh
$ cat <<'EOF' > cloud-init.yaml
#cloud-config
users:
  - name: fedora
    plain_text_passwd: password
    lock_passwd: false
    shell: /bin/bash
    sudo: ALL=(ALL) NOPASSWD:ALL
ssh_pwauth: true
EOF
```

```sh
$ cloud-localds cloud-init.img cloud-init.yaml
```

Creating a differential image - layer - used to work in (this allows us to keep the base image intact while storing all modifications in a separate layer):

```sh
$ qemu-img create -f qcow2 -b fedora-41-base.qcow2 -F qcow2 fedora-working-layer.qcow2
$ ls -s1h *.qcow2
469M fedora-41-base.qcow2
196K fedora-working-layer.qcow2
```

Launch VM with Qemu (step 3):

```sh
$ qemu-system-x86_64 \
    -m 8G \
    -smp 4 \
    -enable-kvm \
    -drive file=fedora-working-layer.qcow2,format=qcow2 \
    -device virtio-vga-gl \
    -display gtk,gl=on \
    -nic user,hostfwd=tcp::2222-:22 \
    -drive file=cloud-init.img,format=raw
```

<img src="qemu-screenshot1.png" />

Access to the VM via ssh (or use `./scripts/enter-in-vm.sh`):

```sh
$ ssh-keygen -R "[localhost]:2222"
$ ssh -o StrictHostKeyChecking=no -p 2222 fedora@localhost
Warning: Permanently added '[localhost]:2222' (ED25519) to the list of known hosts.
[fedora@localhost ~]$
```
