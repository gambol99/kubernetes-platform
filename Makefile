# Makefile for the development clusters

default: local


local:
	@scripts/make-local.sh -C --cluster local \
		--github-token "${GITHUB_TOKEN_personal}"

tenant:
	@scripts/make-local.sh -C --cluster tenant \
	--github-token "${GITHUB_TOKEN_personal}"

clean:
	@echo "Deleting development clusters..."
	@kind delete cluster --name local 2>/dev/null || true
	@kind delete cluster --name tenant 2>/dev/null || true

test:
	@echo "--> Testing the configuration..."
	@$(MAKE) validate
	@$(MAKE) lint

validate:
	@echo "--> Validating the configuration..."
	@$(MAKE) validate-helm-addons
	@$(MAKE) validate-kustomize
	@$(MAKE) validate-kyverno

validate-helm-addons:
	@echo "--> Validating the helm addons..."
	@scripts/validate-helm-addons.sh

validate-kyverno:
	@echo "--> Validating the Kyverno policies..."
	@scripts/validate-kyverno.sh

validate-kustomize:
	@echo "--> Validating the kustomize configuration..."
	@scripts/validate-kustomize.sh

lint-yaml:
	@echo "--> Linting YAML files..."
	@yamllint .

lint:
	@echo "--> Linting the tenant cluster..."
	@$(MAKE) lint-yaml
	@$(MAKE) lint-platform-applications

lint-platform-applications:
	@echo "--> Linting the platform applications..."
	@kubeconform \
		-ignore-missing-schemas \
		kustomize/apps

