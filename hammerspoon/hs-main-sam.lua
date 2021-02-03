

-- INIT

print("Starting, has mic access?")
print(hs.microphoneState(true))
print(hs.keycodes.setLayout("German"))

-- VIEWS

viewManagement = require("view-management")

bind_view(false, "application", {"cmd", "shift", "alt", "ctrl"}, "I", "Discord", "/Users/sam/app/Discord.app")
bind_view(false, "application", {"cmd", "shift", "alt", "ctrl"}, "9", "System Preferences", "/Applications/System Preferences.app")
bind_view(false, "application", {"cmd", "shift", "alt", "ctrl"}, "8", "Activity Monitor", "/Applications/Activity Monitor.app")
bind_view(false, "application", {"cmd", "shift", "alt", "ctrl"}, "U", "FreeTube", "/Users/sam/app/FreeTube.app")
bind_view(false, "application", {"cmd", "shift", "alt", "ctrl"}, "P", "KeePassXC", "/Users/sam/app/KeePassXC.app")
bind_view(false, "application", {"cmd", "shift", "alt", "ctrl" }, "space", "OpenMTP", "/Users/sam/app/OpenMTP.app")
bind_view(false, "application", {"cmd", "shift" }, "<", "Terminal", "/Applications/Terminal.app") 
bind_view(false, "application", {"cmd", "shift" }, "space", "ForkLift", "/Applications/ForkLift.app")

-- TILING

tiling = require("tiling")

hs.hotkey.bind({"cmd", "shift", "alt", "ctrl"}, "ä", function()
  set_layout({name="com.vivaldi.Vivaldi", path="/Users/sam/app/Vivaldi.app"}, {name="net.ankiweb.dtop", path="/Users/sam/app/Anki.app"})
end)
hs.hotkey.bind({"cmd", "shift", "alt", "ctrl"}, "ü", function()
  set_layout({name="com.microsoft.VSCode", path="/Users/sam/app/Code.app"}, {name="net.ankiweb.dtop", path="/Users/sam/app/Anki.app"})
end)
hs.hotkey.bind({"cmd", "shift", "alt", "ctrl"}, "ö", function()
  set_layout({name="com.vivaldi.Vivaldi", path="/Users/sam/app/Vivaldi.app"}, {name="com.microsoft.VSCode", path="/Users/sam/app/Code.app"})
end)

hs.hotkey.bind({"ctrl"}, "+", switchFocusLRwindow)
hs.hotkey.bind({"cmd", "shift", "alt", "ctrl"}, "f", setFullscreen)

windowManager = hs.loadSpoon("WindowHalfsAndThirds")
windowManager:bindHotkeys({
  left_half = {{"cmd", "shift", "alt", "ctrl"}, "j"},
  right_half = {{"cmd", "shift", "alt", "ctrl"}, "k"}
})

-- MEDIA

media = require("media-control")

hs.hotkey.bind({"ctrl"}, "f7", media_controller.prev)
hs.hotkey.bind({"ctrl"}, "f8", media_controller.toggle)
hs.hotkey.bind({"ctrl"}, "f9", media_controller.next)
hs.hotkey.bind({"ctrl", "alt"}, "f8", media_controller.notifyCurrentlyPlaying)

-- META

hs.hotkey.bind({"cmd", "shift", "alt", "ctrl"}, "H", hs.reload)
hs.hotkey.bind({"cmd", "shift", "alt", "ctrl"}, "ß", hs.toggleConsole)

-- MISC

supplementary_window = require("display-supplementary-window")

hs.hotkey.bind({"ctrl"}, "f6", function()
  hs.execute("/Users/sam/ref/res/app/scripts/sh/nightlight-toggle.sh", true)
end)
hs.hotkey.bind({"ctrl", "alt"}, "f6", function()
  hs.notify.show(hs.execute("date", true), "", "")
end)
hs.hotkey.bind({"ctrl", "cmd", "alt"}, "f6", function()
  hs.notify.show("timer started", "", "")
  hs.timer.doAfter(2100, function()
    hs.execute("say サムさんがずっとずっと前から好きでした！付き合ってください！ ", true)
  end)
end)
hs.hotkey.bind({"ctrl", "cmd", "shift", "alt"}, "f6", function()
  hs.timer.doAfter(420, function()
    hs.execute("say サムさんがずっとずっと前から好きでした！付き合ってください！ ", true)
  end)
end)
hs.hotkey.bind({"ctrl"}, "f5", function()
  hs.eventtap.keyStroke({"cmd"}, "c")
  hs.execute('say "' .. hs.pasteboard.getContents() .. '"', true)
end)
hs.hotkey.bind({"ctrl"}, "ß", function()
  hs.eventtap.keyStroke({"cmd"}, "c")
  hs.execute('open -a Vivaldi "https://google.com/search?q=define+$(pbpaste)"', true)
end)
hs.hotkey.bind({"cmd", "shift", "alt"}, "v", function()
  hs.eventtap.keyStrokes(hs.execute('he', true))
end)

-- EXPERIMENTAL

function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end

function createGlobablDiscordKey(modifiers, key, modifiersContainsControl)
  modifiersOutsideOfDiscord = copy(modifiers)
  if not modifiersContainsControl then
    modifiersOutsideOfDiscord[#modifiersOutsideOfDiscord+1]="ctrl"
  end
  hs.hotkey.bind(modifiersOutsideOfDiscord, key, function()
    discord = hs.application.get("Discord")
    hs.timer.doAfter(0.5, function()
      discord:activate()
      hs.eventtap.keyStroke(modifiers, key)
      discord:hide()
    end)
  end)
end

function bindKeyWithFn(modifiers, key, callback)
  keycode=hs.keycodes.map[key]
  hs.eventtap.new({hs.eventtap.event.types.keyDown}, function (e) 	
    -- If Function key held
    if e:getFlags().fn then
      -- test all modifier keys
      for key, value in pairs(modifiers) do
        if not hs.eventtap.checkKeyboardModifiers()[value] then
          return
        end
      end
      print(e:getKeyCode())
      print(keycode)
      if e:getKeyCode() ~= keycode then
        return
      end
      print("executing callback")
      -- It seems that all modifiers are pressed
      callback()
    end
  end):start()
end

createGlobablDiscordKey({"cmd", "shift"}, "m")
createGlobablDiscordKey({"cmd", "shift"}, "d")
createGlobablDiscordKey({"ctrl"}, "ä", true)

bindKeyWithFn({"ctrl"}, "e", function()
  hs.eventtap.keyStroke({"cmd"}, "c")
  hs.notify.show(hs.execute("pbpaste | deepl :en", true), "", "")
end)
bindKeyWithFn({"ctrl"}, "j", function()
  hs.eventtap.keyStroke({"cmd"}, "c")
  hs.notify.show(hs.execute("pbpaste | deepl :ja", true), "", "")
end)
bindKeyWithFn({"ctrl", "cmd"}, "w", function()
  create_new_supplementary_window(hs.execute("weatherwarnings", true), 300, 1000)
end)