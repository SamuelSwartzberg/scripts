

-- INIT

print("Starting, has mic access?")
print(hs.microphoneState(true))
print(hs.keycodes.setLayout("German"))
local supplementary_window = require("display-supplementary-window")
hs.execute("espanso start", true)


-- CHORD MANAGEMENT

allChords = {}
allChords.chords = {}
function allChords:disable() 
  for _, chord in ipairs(self.chords) do
    chord:disable()
  end
end

function createChord(modifiers, key, chordManager)
  hs.hotkey.bind(modifiers, key, function()
    chordManager:enable()
  end)
  allChords.chords[#allChords.chords+1] = chordManager
end

function createChordManager()
  chordManager = {}
  chordManager.shortcuts={}
  function chordManager:enable() 
    print("chord enabled")
    allChords:disable()
    for _, shortcut in ipairs(self.shortcuts) do
      shortcut:enable()
    end
    self.timer = hs.timer.doAfter(2, function()
      self:disable()
    end)
  end

  function chordManager:disable() 
    for _, shortcut in ipairs(self.shortcuts) do
      shortcut:disable()
    end
    if self.timer then
      self.timer:stop()
      self.timer = nil
    end
  end

  function chordManager:addShortcut(modifiers, key, callback) 
    local chordManager=self
    self.shortcuts[#self.shortcuts+1]=hs.hotkey.new(modifiers, key, function()
      chordManager:disable()
      callback()
    end)
  end
  return chordManager
end



-- VIEWS

local viewManagement = require("view-management")

launchChordManager = createChordManager()


launchChordManager:addShortcut( {}, "i", bind_view("com.hnc.Discord"))
launchChordManager:addShortcut( {}, "9", bind_view("com.apple.systempreferences"))
launchChordManager:addShortcut( {}, "8", bind_view( "com.apple.ActivityMonitor"))
launchChordManager:addShortcut( {}, "u", bind_view("io.freetubeapp.freetube"))
launchChordManager:addShortcut( {}, "p", bind_view("org.keepassxc.keepassxc"))
launchChordManager:addShortcut( {}, "a", bind_view("io.ganeshrvel.openmtp"))
launchChordManager:addShortcut( {}, "<", bind_view("com.apple.Terminal"))
launchChordManager:addShortcut( {}, "space", bind_view("com.binarynights.ForkLift-3"))

-- TILING

local tiling = require("tiling")

launchChordManager:addShortcut( {}, "s", function()
  set_layout({name="com.vivaldi.Vivaldi", path="/Users/sam/app/Vivaldi.app"}, {name="net.ankiweb.dtop", path="/Users/sam/app/Anki.app"})
end)
launchChordManager:addShortcut( {}, "m", function()
  set_layout({name="com.microsoft.VSCode", path="/Users/sam/app/Code.app"}, {name="net.ankiweb.dtop", path="/Users/sam/app/Anki.app"})
end)
launchChordManager:addShortcut( {}, "w", function()
  set_layout({name="com.vivaldi.Vivaldi", path="/Users/sam/app/Vivaldi.app"}, {name="com.microsoft.VSCode", path="/Users/sam/app/Code.app"})
end)

hs.hotkey.bind({"ctrl"}, "+", switchFocusLRwindow)
hs.hotkey.bind({"cmd", "shift", "alt", "ctrl"}, "f", setFullscreen)

local windowManager = hs.loadSpoon("WindowHalfsAndThirds")
windowManager:bindHotkeys({
  left_half = {{"cmd", "shift", "alt", "ctrl"}, "j"},
  right_half = {{"cmd", "shift", "alt", "ctrl"}, "k"}
})

createChord({"ctrl", "alt"}, "o", launchChordManager)

-- MEDIA

local media = require("media-control")
local media = require("audio-manager")

mediaChordManager = createChordManager()

mediaChordManager:addShortcut({}, "f7", media_controller.prev)
mediaChordManager:addShortcut({}, "f8", media_controller.toggle)
mediaChordManager:addShortcut({}, "f9", media_controller.next)
mediaChordManager:addShortcut({}, "ß", media_controller.notifyCurrentlyPlaying) -- ß due to ? on the same key
mediaChordManager:addShortcut({}, "o", switchOutputDevice)
mediaChordManager:addShortcut({}, "i", switchInputDevice)

createChord({"ctrl", "alt"}, "m", mediaChordManager)

-- DISCORD

function createDoDiscordKeyOutsideOfDiscord(modifiers, key)
  return createDoKeyOutsideOfApplication("com.hnc.Discord", function()
    hs.eventtap.keyStroke(modifiers, key)
  end)
end

discordChordManager = createChordManager()

discordChordManager:addShortcut({"cmd", "shift"}, "m", createDoDiscordKeyOutsideOfDiscord({"cmd", "shift"}, "m"))
discordChordManager:addShortcut({"cmd", "shift"}, "d", createDoDiscordKeyOutsideOfDiscord({"cmd", "shift"}, "d"))
discordChordManager:addShortcut({"ctrl"}, "ä", createDoDiscordKeyOutsideOfDiscord({"ctrl"}, "ä"))

createChord({"ctrl", "alt"}, "d", discordChordManager)

-- LANGUAGE MANGEMENT

function translatedeepl(command)
  hs.eventtap.keyStroke({"cmd"}, "c")
  hs.execute(command, true)
  hs.timer.doAfter(5, function()
    create_new_supplementary_window(hs.execute("cat /Users/sam/temptransout.txt", true), 300, 800)
    --hs.execute("rm /Users/sam/temptransout.txt", true)
  end)
end

languageChordManager = createChordManager()

languageChordManager:addShortcut({}, "e", function()
  translatedeepl("deeplenfromfile")
end)
languageChordManager:addShortcut({},"j", function()
  translatedeepl("deepljafromfile")
end)

languageChordManager:addShortcut({}, "f5", function()
  hs.eventtap.keyStroke({"cmd"}, "c")
  hs.execute('say "' .. hs.pasteboard.getContents() .. '"', true)
end)

createChord({"ctrl", "alt"}, "l", languageChordManager)

-- UTILITIES

utilityChordManager = createChordManager()

utilityChordManager:addShortcut({}, "u", function()
  create_new_supplementary_window(hs.execute("weatherwarnings", true), 300)
end)
utilityChordManager:addShortcut({}, "w", function()
  hs.notify.show(hs.execute("weather", true), "", "") 
end)
utilityChordManager:addShortcut({}, "d", function() --
  hs.eventtap.keyStroke({"cmd"}, "c")
  hs.timer.doAfter(0.1, function()
    hs.execute('open -a Vivaldi "https:///google.com/search?q=define+$(pbpaste)"', true)
  end)
end)

utilityChordManager:addShortcut({}, "r", hs.reload)
utilityChordManager:addShortcut({}, "c", hs.toggleConsole)

utilityChordManager:addShortcut({},"f6", function()
  hs.execute("/Users/sam/ref/res/app/scripts/sh/nightlight-toggle.sh", true)
end)

utilityChordManager:addShortcut({}, "t", function()
  hs.notify.show(hs.execute("date", true), "", "")
end)

createChord({"ctrl", "alt"}, "u", utilityChordManager)

-- TIMER MANAGEMENT

timerChordManager = createChordManager()

function focusCorrectTab(application)
  application:selectMenuItem(".*termdowwn.*", true)
end

function createDoTermdownKeyOutsideOfTermdown(inputText, submit)
  return createDoKeyOutsideOfApplication("com.apple.Terminal", function()
    focusCorrectTab(hs.application.get("com.apple.Terminal"))
    hs.eventtap.keyStrokes(inputText)
    if submit then hs.eventtap.keyStroke({}, "return") end
  end)
end

timerChordManager:addShortcut({}, "space",  createDoTermdownKeyOutsideOfTermdown("space"))
timerChordManager:addShortcut({}, "+",  createDoTermdownKeyOutsideOfTermdown("+"))
timerChordManager:addShortcut({}, "-",  createDoTermdownKeyOutsideOfTermdown("-"))
timerChordManager:addShortcut({}, "r",  createDoTermdownKeyOutsideOfTermdown("."))
timerChordManager:addShortcut({}, "q",  createDoTermdownKeyOutsideOfTermdown("q"))
local saytext = "サムさんがずっとずっと前から好きでした！付き合ってください！"
for counter = 0, 9 do
  timerChordManager:addShortcut({"shift", "alt"}, tostring(counter),  createDoTermdownKeyOutsideOfTermdown("termdown " .. tostring(counter) .. "5m && say " .. saytext, true))
  timerChordManager:addShortcut({"shift"}, tostring(counter),  createDoTermdownKeyOutsideOfTermdown("termdown " .. tostring(counter) .. "0m && say " .. saytext, true))
  timerChordManager:addShortcut({ "alt"}, tostring(counter),  createDoTermdownKeyOutsideOfTermdown("termdown '" .. tostring(counter) .. "m 30s' && say " .. saytext, true))
  timerChordManager:addShortcut({}, tostring(counter),  createDoTermdownKeyOutsideOfTermdown("termdown " .. tostring(counter) .. "m && say " .. saytext, true))
end
timerChordManager:addShortcut({}, "ß",  function()
  local discord = hs.application.open("com.apple.Terminal", 10, true)
  discord:activate()
  hs.timer.doAfter(2, function()
    discord:hide()
  end)
end)


createChord({"ctrl", "alt"}, "t", timerChordManager)

-- PASTEBOARD MANAGEMENT

pasteboardChordManager = createChordManager()

pasteboardChordManager:addShortcut({},  "c", function()
  hs.eventtap.keyStroke({"cmd"}, "x")
  hs.eventtap.keyStrokes("-s.c-")
end)

pasteboardChordManager:addShortcut({},  "h", function()
  hs.eventtap.keyStrokes(hs.execute('he', true))
end)

pasteboardChordManager:addShortcut({"cmd", "shift"},  "c", function()
  automateMultipleClozes()
end)

function automateMultipleClozes()
  local _, input = hs.dialog.textPrompt("Number of clozes?", "Number of clozes?")
  local numberofcloses = tonumber(input)
  hs.application.open("net.ankiweb.dtop", 10, true)
  hs.execute("espanso stop", true)
  hs.eventtap.keyStroke({"cmd"}, "a")
  hs.eventtap.keyStroke({"cmd"}, "x")
  hs.eventtap.keyStroke({}, "escape")
  hs.execute("pbpaste > /Users/sam/.tempclozetext.txt")
  for i = 1, numberofcloses do
    hs.eventtap.keyStroke({"cmd", "shift"}, "x")
    hs.eventtap.keyStroke({"cmd"}, "a")
    hs.eventtap.keyStrokes(hs.execute("d8 /Users/sam/ref/res/app/scripts/clozesToHTML.js -- '" .. i .. "'", true))
    hs.eventtap.keyStroke({}, "escape")
    hs.eventtap.keyStroke({"cmd"}, "return")
  end
  hs.execute("espanso start", true)
end


createChord({"ctrl", "alt"}, "p", pasteboardChordManager)