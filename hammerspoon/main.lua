
-- INIT

print("Starting, has mic access?")
print(hs.microphoneState(true))
print(hs.keycodes.setLayout("German"))

-- VIEWS

viewManagement = require("view-management")

bind_view(false, "application", {"cmd", "shift", "alt", "ctrl"}, "I", "Discord", "/Users/sam/app/Discord.app")
bind_view(false, "application", {"cmd", "shift", "alt", "ctrl"}, "9", "System Preferences", "/Applications/System Preferences.app")
bind_view(false, "application", {"cmd", "shift", "alt", "ctrl"}, "8", "Activity Monitor", "/Applications/Activity Monitor.app")
bind_view(false, "application", {"cmd", "shift", "alt", "ctrl" }, "M", "Mailspring", "/Users/sam/app/Mailspring.app")
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

hs.hotkey.bind({}, "f7", media_controller.prev)
hs.hotkey.bind({}, "f8", media_controller.toggle)
hs.hotkey.bind({}, "f9", media_controller.next)
hs.hotkey.bind({"alt"}, "f8", media_controller.notifyCurrentlyPlaying)

-- META

hs.hotkey.bind({"cmd", "shift", "alt", "ctrl"}, "H", hs.reload)
hs.hotkey.bind({"cmd", "shift", "alt", "ctrl"}, "ß", hs.toggleConsole)

-- MISC

hs.hotkey.bind({}, "f6", function()
  hs.execute("/Users/sam/ref/res/app/scripts/sh/nightlight-toggle.sh", true)
end)

