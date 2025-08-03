# Builds the container from the image
podman build \
    --squash \
    --tag localhost/ansible-venv \
    --file $(dirname "${BASH_SOURCE[0]}")/ansible-venv.Containerfile