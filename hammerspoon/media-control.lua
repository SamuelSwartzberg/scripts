local globals = require("globals")

media_controller = {}
function media_controller:next()
  print(hs.execute("mpc next", true))
end
function media_controller:prev()
  print(hs.execute("mpc prev", true))
end
function media_controller:toggle()
  print(hs.execute("mpc toggle", true))
end
function media_controller:notifyCurrentlyPlaying()
  print("notfying currently playing")
  hs.notify.show(hs.execute("mpc | head -n 1", true), "", "")
end

