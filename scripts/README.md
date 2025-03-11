# Scripts

This directory contains the scripts used to bootstrap the platform.

- `generate-policies.sh`: Used to generate the Kyverno policy documentation.
- `make-dev.sh`: Used for local development, it will build a kind cluster and bootstrap the platform using your branch as the entry point.
- `make-spoke.sh`: Used to provision an empty spoke cluster, ready to be joined to the hub.
- `update-helm-charts.sh`: Used to update the cluster secret from the definition, without waiting for the sync to occur.
- `validate-helm-addons.sh`: Used to validate the helm add-ons files conform to the expected format.
- `validate-helm-charts.sh`: Used to ensure the embedded helm charts are valid.
- `validate-kustomize-addons.sh`: Used to validate the Kustomize add-ons files conform to the expected format.
- `validate-kustomize.sh`: Used to validate the Kustomize configuration from overlay to applications.
- `validate-kyverno.sh`: Used to validate the Kyverno policies conform to the expected format.
