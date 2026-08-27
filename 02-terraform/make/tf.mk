INFRA_DIR := infra
VENV_PYTHON := $(CURDIR)/../.venv/Scripts/python.exe
CHECKOV_SCRIPT := $(CURDIR)/../.venv/Scripts/checkov
.PHONY: tf.init tf.init.liu tf.validate tf.plan tf.apply tf.fmt.ci tf.fmt tf.lint

tf.validate:
	@terraform -chdir=$(TF_ENV_DIR) validate

tf.plan:
	@terraform -chdir=$(TF_ENV_DIR) plan

tf.apply:
	@terraform -chdir=$(TF_ENV_DIR) apply

tf.fmt:
	@terraform fmt -recursive -diff $(INFRA_DIR)

tf.fmt.ci:
	@terraform fmt -recursive -check $(INFRA_DIR)

tf.lint:
	@$(VENV_PYTHON) $(CHECKOV_SCRIPT) -d $(INFRA_DIR)
	@trivy config $(INFRA_DIR)

tf.init.liu:
	@terraform -chdir=$(TF_ENV_DIR) init -lock=false -input=false -upgrade