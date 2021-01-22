let startsWith = arguments[0].toLowerCase();
console.log("Words that start with: " + startsWith);
let wordList = read("/Users/sam/.english-words-500k.txt");
let wordArray = wordList.split("\n");
let matches = wordArray.filter(line=>line.toLowerCase().startsWith(startsWith));
let matchesFormatted = matches.join("\n");
console.log(matchesFormatted);