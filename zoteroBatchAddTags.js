var s = new Zotero.Search();
s.libraryID = Zotero.Libraries.userLibraryID;
s.addCondition('tag', 'contains', '§');
var ids = await s.search();
let myTag = await Zotero.DB.executeTransaction(async function () {
  for (let id of ids) {
    let item = await Zotero.Items.getAsync(id);
    let tagstring = "";
    let paraMarkedTags = item.getTags().filter(individTag => individTag.tag.includes("§"));
    for (tag of paraMarkedTags) {
      tagstring += tag.tag;

    }
    item.setField("title", item.getField("title") + tagstring);
    Zotero.log(item.getField("title"));
    await item.save();

  }
});

var s = new Zotero.Search();
s.libraryID = Zotero.Libraries.userLibraryID;
s.addCondition('tag', 'contains', '§');
var ids = await s.search();

let myTag = await Zotero.DB.executeTransaction(async function () {
  let tempitem;
  for (let id of ids) {
    let item = await Zotero.Items.getAsync(id);
    tempitem = item;

    // Zotero.File.rename(currentFile, newName)
  }
  let zotKeys = Object.keys(tempitem).sort();
  for (item of zotKeys) {
    Zotero.log(item);
  }
  Zotero.log(Zotero.Items);
  Zotero.log(item.file);
});
