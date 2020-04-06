# Packet-Fedora

Create Fedora artifacts for Packet.net custom image.

## Requirements

- HashiCorp/packer
- QEMU
- edk2-ovmf

## Setup

Create a `packer` group and add the user running packer to this.

```shell
sudo groupadd packer
usermod -a -G packer $USER
```

Substitute `SSH-PUBLIC-KEY` in `http/fedora-ks.cfg` with the public key
for the provisioner user.  This packer template makes use of the ssh-agent
to authenticate to the virtual machine.  Ensure the key is added to the agent
with `ssh-add /path/to/provisoner/key`.

## Creating The Artifacts

```shell
packer build -var 'version=31' -var 'release=1.9' fedora.json
```

The `output` directory will contain the necessary `.tar.gz` files to be used.
