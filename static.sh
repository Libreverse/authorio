echo "====================="
echo "Rubocop results"
echo "====================="
bundle exec rubocop -A

echo "====================="
echo "eslint results"
echo "====================="
bunx eslint . --fix

echo "====================="
echo "Stylelint results"
echo "====================="
bunx stylelint "**/*.scss" --fix

echo "====================="
echo "markdownlint results"
echo "====================="
bunx markdownlint-cli2 '**/*.md' '!**/node_modules/**' '!**/licenses/**' --fix

echo "====================="
echo "Prettier results"
echo "====================="
bunx prettier . --write

echo "====================="
echo "All static analysis checks performed"
echo "====================="
