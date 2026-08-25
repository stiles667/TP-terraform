INFRA_DIR := infra
.PHONY: tf.init tf.validate tf.plan tf.apply tf.fmt.ci tf.fmt

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