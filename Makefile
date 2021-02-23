.PHONY: $(shell egrep -o ^[a-zA-Z_-]+: $(MAKEFILE_LIST) | sed 's/://')

help: ## Print this help
	@echo "Usage: make [target] (module=[terraform module name])"
	@echo
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

init: ## exec docker-compose build & npx zenn init
	@docker-compose build
	@docker-compose run --rm npx zenn init

preview: ## exec npx zenn preview
	@docker-compose up

article: ## exec npx zenn new:article
	@docker-compose run --rm npx zenn new:article

book: ## exec npx zenn new:book
	@docker-compose run --rm npx zenn new:book
