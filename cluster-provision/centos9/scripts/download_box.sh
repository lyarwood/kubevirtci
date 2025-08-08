#!/bin/bash

set -e
set -o pipefail

ARCH=$(uname -m)
case "$ARCH" in
"amd64")
  curl -L --fail https://cloud.centos.org/centos/9-stream/x86_64/images/CentOS-Stream-Vagrant-9-"$centos_version".x86_64.vagrant-libvirt.box | tar -zxvf - box.img
  qemu-img convert -O qcow2 box.img box.qcow2
  curl -L -o /initramfs-amd64.img http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/images/pxeboot/initrd.img
  curl -L -o /vmlinuz-amd64 http://mirror.stream.centos.org/9-stream/BaseOS/x86_64/os/images/pxeboot/vmlinuz
  ;;
"s390x")
  curl -L --fail -o box.qcow2 https://cloud.centos.org/centos/9-stream/s390x/images/CentOS-Stream-GenericCloud-9-"$centos_version".s390x.qcow2
  # Access virtual machine disk images directly by using LIBGUESTFS_BACKEND=direct, instead of libvirt
  LIBGUESTFS_BACKEND=direct guestfish --ro --add box.qcow2 --mount /dev/sda1:/ ls /boot/ | grep -E '^vmlinuz-|^initramfs-' | xargs -I {} guestfish --ro --add box.qcow2 -i copy-out /boot/{} /
  ;;
*)
  echo "unknown arch $ARCH"
  ;;
esac
