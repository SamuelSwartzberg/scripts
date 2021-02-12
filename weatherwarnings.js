let weatherwarnings = read("/Users/sam/tempweatherwarnings.json");
if (!weatherwarnings) throw new Error("No weatherwarnings found or file was empty");
if (weatherwarnings.length < 30) throw new Error("File unreasonably short, aborting. Content was " + weatherwarnings)
let weatherwarningscleaned = weatherwarnings.replace("warnWetter.loadWarnings(", "").replace(");", "");
let parsedwarnings = JSON.parse(weatherwarningscleaned);
let munichwarnings = Object.values(parsedwarnings.warnings).filter(item =>{
  firstChildItem = item[0];
  if (firstChildItem.regionName.includes("München")) return true;
})
console.log(munichwarnings[0][0].regionName + "\n")
  for (let subwarning of munichwarnings[0]){
      let timelengthstr = new Date(subwarning.start).toLocaleTimeString().replace(":00 PM", " PM") + ` (${Math.round((subwarning.end-subwarning.start)/(1000*60*60))}h)`;
      console.log(subwarning.event+ "\n")
      console.log("Level: " + subwarning.level + " - " + timelengthstr + "\n")
      console.log(subwarning.description)
      console.log("\n\n")
    

}