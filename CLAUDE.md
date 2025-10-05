# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Zenn content repository for managing technical articles and books written in Japanese. Zenn is a Japanese platform for publishing technical content. All content is written in Markdown and managed via the Zenn CLI.

## Development Environment

All commands run inside a Docker container with Node.js LTS Alpine. The container includes:
- zenn-cli (Zenn's official CLI)
- textlint with Japanese technical writing presets

## Common Commands

All commands are executed via Makefile targets:

```bash
# Build Docker image
make build

# Initialize Zenn (first time setup)
make init

# Preview articles locally at http://localhost:8000
make preview

# Create a new article with a specific slug
make article slug=your-article-slug

# Create a new book with a specific slug
make book slug=your-book-slug

# Lint all articles and books
make textlint
```

## Content Structure

- **articles/**: Individual technical articles in Markdown format
  - Each article has frontmatter with: title, emoji, type (tech/idea), topics, published status
  - Articles use Zenn's Markdown dialect with special syntax like `:::message` and `:::details`

- **books/**: Book content (currently empty but structure exists)

## Writing Guidelines (from .textlintrc)

When editing articles:
- Maximum sentence length: 150 characters (Japanese)
- Exclamation marks (！、？) are allowed
- Weak phrases like 「かも」「思います」are allowed
- Successive words (スラング) like 「あるある」「つよつよ」are allowed
- Zenn's special Markdown blocks (`:::message`, `:::details`) are used and should be preserved
- Must maintain consistent です/ます form (no mixing with だ/である form)
- Tech terminology must be spelled correctly per textlint-rule-spellcheck-tech-word

## CI/CD

GitHub Actions runs textlint on all pull requests via `.github/workflows/test.yml` which executes `make build && make textlint`.

## Important Notes

- All content is in Japanese
- Article filenames can be either a slug or a hash (e.g., `050e408742dc0522f752.md` or `terraform-nested-for-each-loop.md`)
- Zenn platform documentation: https://zenn.dev/zenn/articles/zenn-cli-guide
- Zenn Markdown guide: https://zenn.dev/zenn/articles/markdown-guide