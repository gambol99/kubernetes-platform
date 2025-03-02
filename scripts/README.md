# Scripts

This directory contains the scripts used to bootstrap the platform.

- `make-dev.sh`: Used for local development, it will build a kind cluster and bootstrap the platform using your branch as the entry point.
- `validate-helm-addons.sh`: Used to validate the helm add-ons files conform to the expected format.
- `validate-kustomize-addons.sh`: Used to validate the Kustomize add-ons files conform to the expected format.
- `validate-kustomize.sh`: Used to validate the Kustomize configuration from overlay to applications.
- `validate-kyverno.sh`: Used to validate the Kyverno policies conform to the expected format.
- `validate-helm-charts.sh`: Used to ensure the embedded helm charts are valid.
