.PHONY: init
init:
	terraform init -backend-config="bucket=$(REMOTE_STATE_BUCKET)" -backend-config="key=$(REMOTE_STATE_KEY)"

.PHONY: apply
apply: init
	terraform apply -var prefix=$(prefix)

REMOTE_STATE_BUCKET="cdt-terraform"
REMOTE_STATE_KEY = "$(prefix)-ecs.json"
