
init:
	# https://kyverno.io/blog/2023/12/12/kyverno-chainsaw-the-ultimate-end-to-end-testing-tool/#getting-started
	# create a cluster
	docker pull docker.io/rancher/mirrored-pause:3.6
	docker pull rancher/klipper-helm:v0.8.3-build20240228
	docker pull rancher/mirrored-coredns-coredns:1.10.1
	docker pull rancher/local-path-provisioner:v0.0.26
	docker pull docker.io/rancher/mirrored-metrics-server:v0.7.0
	docker pull rancher/mirrored-library-traefik:2.10.5
	docker pull rancher/klipper-lb:v0.4.7

	k3d cluster delete chainsaw
	k3d cluster create chainsaw --agents 1

	k3d image import rancher/klipper-lb:v0.4.7 -c chainsaw
	k3d image import rancher/mirrored-library-traefik:2.10.5 -c chainsaw
	k3d image import docker.io/rancher/mirrored-metrics-server:v0.7.0 -c chainsaw
	k3d image import rancher/local-path-provisioner:v0.0.26 -c chainsaw
	k3d image import rancher/klipper-helm:v0.8.3-build20240228 -c chainsaw
	k3d image import docker.io/rancher/mirrored-pause:3.6 -c chainsaw
	k3d image import rancher/mirrored-coredns-coredns:1.10.1 -c chainsaw
	# deploy rbac-manager
	helm install rbac-manager --repo https://charts.fairwinds.com/stable rbac-manager --namespace rbac-manager --create-namespace

install:
#	brew install kyverno
#	kyverno version
	brew tap kyverno/chainsaw https://github.com/kyverno/chainsaw
	brew install kyverno/chainsaw/chainsaw
	chainsaw version

chainsaw:
	chainsaw test ./chainsaw/1-rbac-test

2:
	chainsaw test ./chainsaw/2-test

include ./.platform/colima.mk

