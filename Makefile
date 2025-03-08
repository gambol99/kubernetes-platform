# Makefile for the development clusters

GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)

standalone:
	@echo "Provisioning Standalone Cluster (dev)"
	@scripts/make-dev.sh \
		--cluster-type standalone \
	  --cluster dev

hub:
	@echo "Provisioning Hub Cluster (hub)"
	@scripts/make-dev.sh \
		--cluster-type hub \
		--cluster hub

spoke:
	@echo "Provisioning Spoke Cluster (spoke)"
	@scripts/make-spoke.sh --cluster spoke

clean:
	@echo "Deleting development clusters..."
	@kind delete cluster --name dev 2>/dev/null || true
	@kind delete cluster --name hub 2>/dev/null || true
	@kind delete cluster --name spoke 2>/dev/null || true

test:
	@echo "--> Testing the configuration..."
	@$(MAKE) validate
	@$(MAKE) lint

e2e:
	@echo "--> Running the e2e tests..."
	@$(MAKE) standalone
	@tests/check-suite.sh

trigger-e2e:
	echo "--> Triggering the e2e tests..."
	@gh workflow run e2e.yml --ref ${GIT_BRANCH}

validate:
	@echo "--> Validating the configuration..."
	@$(MAKE) validation-actions
	@$(MAKE) validate-helm-addons
	@$(MAKE) validate-kustomize
	@$(MAKE) validate-helm-charts
	@$(MAKE) validate-kyverno

validate-actions:
	@echo "--> Validating Github Actions..."
	@actionlint

validate-helm-addons:
	@echo "--> Validating the helm addons..."
	@scripts/validate-helm-addons.sh

validate-kyverno:
	@echo "--> Validating the Kyverno policies..."
	@scripts/validate-kyverno.sh

validate-kustomize:
	@echo "--> Validating the kustomize configuration..."
	@scripts/validate-kustomize.sh

validate-helm-charts:
	@echo "--> Validating Helm Charts..."
	@scripts/validate-helm-charts.sh

validate-docs:
	@echo "--> Validating the documentation..."
	@$(MAKE) validate-docs-spelling

validate-docs-spelling:
	@echo "--> Spell Checking Docs"
	@misspell docs

lint-yaml:
	@echo "--> Linting YAML files..."
	@yamllint .

lint:
	@echo "--> Linting the tenant cluster..."
	@$(MAKE) lint-yaml
	@$(MAKE) lint-platform-applications

lint-platform-applications:
	@echo "--> Linting the platform applications..."
	@kubeconform -ignore-missing-schemas apps

