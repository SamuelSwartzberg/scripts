sort --ignore-case -o /Users/sam/.code-glossary.tsv  /Users/sam/.code-glossary.tsv
result=`d8 ../update-code-settings.js`
echo "$result" > "/Users/sam/Library/Application Support/Code/User/settings.json"