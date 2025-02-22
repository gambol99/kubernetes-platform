# Scripts

This directory contains the scripts used to bootstrap the platform.

- `make-local.sh`: Used for local development, it will build a kind cluster and bootstrap the platform using your branch as the entrypoint.
- `validate-helm-addons.sh`: Used to validate the helm addons files conform to the expected format.
- `validate-kustomize-addons.sh`: Used to validate the kustomize addons files conform to the expected format.
- `validate-kustomize.sh`: Used to validate the kustomize configuration from overlay to applications.
- `validate-kyverno.sh`: Used to validate the kyverno policies conform to the expected format.
