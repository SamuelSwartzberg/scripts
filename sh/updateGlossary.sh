key="$1"
value="$2"
echo "$1	$2" >> /Users/sam/.code-glossary.tsv
result=`d8 ../update-code-settings.js -- "$1" `
echo "$result" > "/Users/sam/Library/Application Support/Code/User/settings.json"