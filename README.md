#Packet-Fedora

Create Fedora artifacts for Packet.net custom image.

## Requirements
- Hashicorp/packer
- pykickstart
- QEMU

## Setup

Create a `packer` group and add the user running packer to this.

```
sudo groupadd packer
usermod -a -G packer $USER
```

In order to maintain file permissions and operate without authentication prompts
add the `res/80-packer.rules` to `/etc/polkit-1/rules.d`.  These rules allow
`tar` and `cp` to run as root and mount the raw image on a loop device.

```
sudo cp res/80-packer.rules /etc/polkit-1/rules.d/`
```

Substitute `SSH-PUBLIC-KEY` in `http/fedora-ks.cfg` with the public key
for the provisioner user.  This packer template makes use of the ssh-agent
to authenticate to the virtual machine.  Ensure the key is added to the agent
with `ssh-add /path/to/my/key`.

## Creating The Artifacts

```
packer build fedora-x86_64.json
```

The `output` directory will contain the necessary `.tar.gz` files to be used.
