settingsJsonString = read("/Users/sam/Library/Application Support/Code/User/settings.json")
glossaryTSVData = read("/Users/sam/.code-glossary.tsv");
glossaryArray = glossaryTSVData.split("\n").map(item=>item.split("\t")[0]);
settingsObject = JSON.parse(settingsJsonString);
glossaryArray.sort((item1, item2)=>{
  let item1amountOfWords = item1.split(" ").length;
  let item2amountOfWords = item2.split(" ").length;
  if (item1amountOfWords >= item2amountOfWords) return -1;
  else return 1;
})
settingsObject["todohighlight.keywords"] = glossaryArray;
console.log(JSON.stringify(settingsObject));
