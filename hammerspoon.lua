function launch_webview( url, name, width, height )
  local title = name
  width = width or 800
  height = height or 600
  local rect = hs.geometry.rect(2560/2-width/2, 1600/2-height/2, width, height)
  local wv = hs.webview.new( rect )
                        :url(url)
                        :allowGestures(true)
                        :windowTitle(title)
                        :allowTextEntry(true)
                        :allowNewWindows(false)
                        :windowStyle({"borderless", "resizable"})
                        :deleteOnClose(true)
                        :userAgent("Mozilla/5.0 (Macintosh; Intel Mac OS X 11_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.141 Safari/537.36")
                        :show()
  return wv
end

views = {}

print("Starting, has mic access?")
print(hs.microphoneState(true))
print(hs.keycodes.setLayout("German"))

function to_front_if_open()
  for key, val in pairs(views) do 
    if val and not val.hidden then
      val.view:bringToFront()
    end
  end
end

-- currently unused
function hide_all_others()
  for key, val in pairs(views) do 
    val:hide()
  end
end

-- debug only
function debug_table(table)
  for key, val in pairs(table) do 
    print(key)
    print(val)
  end
end

timer = hs.timer.doEvery(0.1, to_front_if_open)

function get_semipermantent_webview(name, url, width, height)

  webview = {view = launch_webview(url, name, width, height), hidden = false}

  function webview:hide()
    self.view:hide()
    self.hidden = true
  end

  function webview:show()
    self.view:show()
    self.hidden = false
  end

  return webview

end

function get_selfdestructive_webview(name, url, width, height)

  webview = {view = launch_webview(url, name, width, height), hidden = false}

  function webview:hide()
    views[name].view:delete()
    views[name] = nil
  end

  function webview:show()
    print("does nothing")
  end

  return webview

end

function get_webview(destructive, name, location, width, height)
  if destructive then
    return get_selfdestructive_webview(name, location, width, height)
  else
    return get_semipermantent_webview(name, location, width, height)
  end
end

function show_hide(view)
  if view.view:isVisible() then
    view:hide()
  else
    view:show()
  end
end

function bind_view(destructive, modifiers, key, name, location, width, height)
  hs.hotkey.bind(modifiers, key, function()
    if views[name] then
      show_hide(views[name])
    else 
      views[name] = get_webview(destructive, name, location, width, height)
    end
  end)
end


bind_view(false, {"cmd", "alt"}, "D", "Discord", "https://discord.com/channels/@me")
bind_view(true, {"cmd", "alt"}, "ä", "Youtube", "https://www.youtube.com/")

