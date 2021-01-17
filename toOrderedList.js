

try {
  let listtype = arguments[0];
  let query = read("/Users/sam/manipulation_temp.txt");
  let finalString = "";
  let lineArray = query.split("\n");
  lineArray.forEach(element => finalString = finalString + "  <li>" + element + "</li>\n");
  finalString = finalString.slice(0, -1);
  finalString = `<${listtype}>\n` + finalString + `\n</${listtype}>`;
  console.log(finalString);
} catch (error) { console.log(error); }
