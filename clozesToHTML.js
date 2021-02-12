let inputtext = read("/Users/sam/.tempclozetext.txt");
let index = parseInt(arguments[0]);

inputtext = inputtext.replace(new RegExp("{{c[^"+ index +"]::([^}]+[^}])}}", "gim"), "$1")
inputtext = inputtext.replace(new RegExp("{{c"+ index +"::([^}]+[^}])}}", "gim"), "<span class='cloze'>$1</span>")
console.log(inputtext);