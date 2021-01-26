

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



