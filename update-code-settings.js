key=arguments[0];
settingsJsonString = read("/Users/sam/Library/Application Support/Code/User/settings.json")
settingsObject = JSON.parse(settingsJsonString);
settingsObject["todohighlight.keywords"].push(key);
console.log(JSON.stringify(settingsObject));
