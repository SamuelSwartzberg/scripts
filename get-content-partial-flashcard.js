let contentstring = read("/Users/sam/tempjson.json");
let contentjson = JSON.parse(contentstring);
console.log(
  contentjson.filter(mediaItem => String(mediaItem.flashcardified).includes("partial"))
  .map(mediaItem => mediaItem.name)
  .join("\n")
);