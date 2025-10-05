#!/bin/bash

# Extract file path from hook input
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.file_path')

# Only run textlint on markdown files in articles/ or books/
if [[ "$FILE_PATH" == articles/*.md ]] || [[ "$FILE_PATH" == books/*.md ]]; then
  echo "Running textlint on $FILE_PATH..."
  docker compose run --rm npx textlint "$FILE_PATH"

  if [ $? -ne 0 ]; then
    echo "❌ textlint failed. Please fix the errors above."
    exit 1
  fi

  echo "✅ textlint passed"
fi

exit 0