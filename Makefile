# Makefile for the development clusters

GIT_BRANCH := $(shell git rev-parse --abbrev-ref HEAD)
LAST_TAG ?= $(shell git tag --sort=-version:refname | head -n 2 | tail -n 1)

standalone:
	@echo "--> Provisioning Standalone Cluster (dev)"
	@scripts/make-dev.sh \
		--cluster-type standalone \
	  --cluster dev

standalone-aws:
	@echo "--> Provisioning Standalone Cluster (dev) in AWS"
	@cd terraform && make init
	@cd terraform && make dev

destroy-standalone-aws:
	@echo "--> Destroying Standalone Cluster (dev) in AWS"
	@cd terraform && make init
	@cd terraform && make destroy-dev

hub:
	@echo "--> Provisioning Hub Cluster (hub)"
	@scripts/make-dev.sh \
		--cluster-type hub \
		--cluster hub

hub-aws:
	@echo "--> Provisioning Hub Cluster (hub) in AWS"
	@cd terraform && make init
	@cd terraform && make hub

destroy-hub-aws:
	@echo "--> Destroying Hub Cluster (hub) in AWS"
	@cd terraform && make init
	@cd terraform && make destroy-hub

spoke:
	@echo "Provisioning Spoke Cluster (spoke)"
	@scripts/make-spoke.sh --cluster spoke

spoke-aws:
	@echo "--> Provisioning Spoke Cluster (spoke) in AWS"
	@cd terraform && make init
	@cd terraform && make spoke

destroy-spoke-aws:
	@echo "--> Destroying Spoke Cluster (spoke) in AWS"
	@cd terraform && make init
	@cd terraform && make destroy-spoke

serve-docs:
	@echo "--> Serving the documentation..."
	@cd docs && mkdocs serve

clean:
	@echo "Deleting development clusters..."
	@kind delete cluster --name dev 2>/dev/null || true
	@kind delete cluster --name hub 2>/dev/null || true
	@kind delete cluster --name spoke 2>/dev/null || true

changelog:
	@echo "--> Generating the changelog..."
	@git-cliff \
		--config .cliff/cliff.toml \
		--github-repo gambol99/kubernete-platform \
		$(LAST_TAG)..HEAD

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
	@$(MAKE) validate-actions
	@$(MAKE) validate-cluster-definitions
	@$(MAKE) validate-helm-addons
	@$(MAKE) validate-kustomize
	@$(MAKE) validate-helm-charts
	@$(MAKE) validate-kyverno

validate-cluster-definitions:
	@echo "--> Validating the cluster definitions..."
	@scripts/validate-cluster-definitions.sh

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

