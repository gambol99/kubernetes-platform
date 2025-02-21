# Makefile for the development clusters

default: test

test:
	@echo "Testing the platform..."
	@kubectl apply -k kustomize/overlays/release --dry-run=client -o yaml > /dev/null

clean:
	@echo "Deleting development clusters..."
	@kind delete cluster --name grn
	@kind delete cluster --name yel

lint: 
	@echo "Linting the tenant cluster..."
	$(MAKE) lint-platform-applications

lint-platform-applications:
	@echo "Linting the platform applications..."
	@kubeconform \
		-ignore-missing-schemas \
		kustomize/base

