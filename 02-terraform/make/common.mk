.ONESHELL:
SHELL := /usr/bin/bash
.SHELLFLAGS := -eu -o pipefail -c
INFO_COLOR    := \033[36;1m
ERROR_COLOR   := \033[31;1m
SUCCESS_COLOR := \033[32;1m
WARNING_COLOR := \033[33;1m
RESET_COLOR   := \033[0m

ENV ?= dev
INFRA_DIR := $(CURDIR)/infra
TF_ENV_DIR ?= $(INFRA_DIR)/envs/$(ENV)
ANSI_DIR := ansible

tf.init:
	@terraform -chdir=$(TF_ENV_DIR) init
help: ## shows this help
	@echo -e "$(INFO_COLOR)============ MENU ============$(RESET_COLOR)"
	@grep -E '^[a-zA-Z0-9_-]+:.*##' $(MAKEFILE_LIST) | awk -F':.*##' '{printf "$(INFO_COLOR)%-20s$(RESET_COLOR) %s\n", $$1, $$2}'
	@echo -e "$(INFO_COLOR)============ END OF MENU ============$(RESET_COLOR)"
