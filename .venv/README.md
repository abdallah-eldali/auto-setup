# Description

Using `podman` and `toolbox`, we can create a virtual development environment for Ansible development.

## Build Image

To build an image, run the `build.sh` bash script, it will create an image with the tag `localhost/ansible-venv`

## Save Image as a Tar file

```bash
$ podman save --output my-toolbox-image.tar my-toolbox-image
```

## Enter Save Image with Toolbox

1. Load the image
```bash
$ podman load --input my-toolbox-image.tar
```
2. Enter the image with `toolbox`
```
$ toolbox enter my-toolbox-image
```

You can also use VSCodium with Red Hat's Ansible extension and Microsoft's Dev Container