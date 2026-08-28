SHELL := /usr/bin/env bash
.SHELLFLAGS := -eu -o pipefail -c

TF_DIR := ../02-terraform/infra/envs/dev
ANSIBLE_DIR := ../03-ansible
BUILD_DIR := build
TERRAFORM_OUTPUTS := $(BUILD_DIR)/terraform-outputs.json
INVENTORY := $(BUILD_DIR)/inventory.ini
TERRAFORM ?= $(or $(shell command -v terraform 2>/dev/null),$(shell command -v terraform.exe 2>/dev/null),/mnt/c/Users/ilyas/AppData/Local/chocolatey/bin/terraform.exe)

.PHONY: init validate plan apply inventory ping deploy build ci docker-build clean

init:
	$(TERRAFORM) -chdir=$(TF_DIR) init -input=false

validate:
	$(TERRAFORM) -chdir=$(TF_DIR) init -backend=false -input=false
	$(TERRAFORM) -chdir=$(TF_DIR) validate
	ANSIBLE_CONFIG=$(ANSIBLE_DIR)/ansible.cfg ansible-playbook -i localhost, $(ANSIBLE_DIR)/site.yml --syntax-check

plan:
	$(TERRAFORM) -chdir=$(TF_DIR) plan

apply:
	$(TERRAFORM) -chdir=$(TF_DIR) apply


.build-dir:
	mkdir -p $(BUILD_DIR)
	touch $@

$(TERRAFORM_OUTPUTS): | .build-dir
	$(TERRAFORM) -chdir=$(TF_DIR) output -json > $@.tmp
	test -s $@.tmp
	mv $@.tmp $@

inventory: $(TERRAFORM_OUTPUTS)
	$(TERRAFORM) -chdir=$(TF_DIR) output -json > $(TERRAFORM_OUTPUTS).tmp
	test -s $(TERRAFORM_OUTPUTS).tmp
	mv $(TERRAFORM_OUTPUTS).tmp $(TERRAFORM_OUTPUTS)
	python3 scripts/generate_inventory.py --terraform-output $(TERRAFORM_OUTPUTS) --output $(INVENTORY)

ping: inventory
	ANSIBLE_CONFIG=$(ANSIBLE_DIR)/ansible.cfg ansible -i $(INVENTORY) web -m ping

deploy: inventory
	ANSIBLE_CONFIG=$(ANSIBLE_DIR)/ansible.cfg ansible-playbook -i $(INVENTORY) $(ANSIBLE_DIR)/site.yml

build: apply inventory deploy
	@printf '\nDeployment completed from Terraform to Ansible.\n'

ci:
	$(TERRAFORM) -chdir=$(TF_DIR) init -backend=false -input=false
	$(TERRAFORM) -chdir=$(TF_DIR) fmt -check -recursive
	$(TERRAFORM) -chdir=$(TF_DIR) validate
	python3 -m py_compile scripts/generate_inventory.py
	ANSIBLE_CONFIG=$(ANSIBLE_DIR)/ansible.cfg ansible-playbook -i localhost, $(ANSIBLE_DIR)/site.yml --syntax-check

docker-build:
	docker build -f CI-CD-proj-final/Dockerfile -t iac-ci-tools:local ..

clean:
	rm -rf $(BUILD_DIR)
