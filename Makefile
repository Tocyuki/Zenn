.DEFAULT_GOAL := help
.PHONY: $(shell egrep -o ^[a-zA-Z_-]+: $(MAKEFILE_LIST) | sed 's/://')

help: ## Print this help
	@echo "Usage: make <target>"
	@echo
	@echo 'Available targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build Docker image
	@docker compose build --pull

rebuild: ## Rebuild Docker image without cache
	@docker compose build --no-cache --pull

init: build ## Initialize Zenn project (first time setup)
	@docker compose run --rm npx zenn init

preview: ## Start local preview server at http://localhost:8000
	@docker compose up

preview-d: ## Start local preview server in background
	@docker compose up -d

stop: ## Stop preview server
	@docker compose down

article: ## Create new article (usage: make article slug=your-slug)
	@if [ -z "$(slug)" ]; then \
		echo "Error: slug is required. Usage: make article slug=your-slug"; \
		exit 1; \
	fi
	@docker compose run --rm npx zenn new:article --slug $(slug)

book: ## Create new book (usage: make book slug=your-slug)
	@if [ -z "$(slug)" ]; then \
		echo "Error: slug is required. Usage: make book slug=your-slug"; \
		exit 1; \
	fi
	@docker compose run --rm npx zenn new:book --slug $(slug)

textlint: ## Run textlint on all markdown files
	@docker compose run --rm npx textlint "articles/**/*.md" "books/**/*.md" 2>/dev/null || true

textlint-fix: ## Auto-fix textlint errors
	@docker compose run --rm npx textlint --fix "articles/**/*.md" "books/**/*.md" 2>/dev/null || true

lint: textlint ## Alias for textlint

clean: ## Remove Docker containers and volumes
	@docker compose down -v

logs: ## Show preview server logs
	@docker compose logs -f
