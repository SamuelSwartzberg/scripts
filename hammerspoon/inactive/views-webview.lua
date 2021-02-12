globals = require("globals")

function launch_webview( name, url, width, height )
  userscript = hs.webview.usercontent.new(name)
  if name == "MDN" then
    userscript:injectScript({source = "let search = document.querySelector('#main-q'); search.focus(); search.select();", injectionTime = "documentEnd"})
  elseif name == "Jisho" then
    userscript:injectScript({source = "let search = document.querySelector('#keyword'); search.focus(); search.select();", injectionTime = "documentEnd"})
  elseif name == "dictcc" then
    userscript:injectScript({source = "document.querySelector('head').append('<link rel=\"stylesheet\" src=\"https://raw.githubusercontent.com/SamuelSwartzberg/scripts/master/dictcc.css\">')", injectionTime = "documentEnd"})
  end
  width = width or 1000
  height = height or 800
  local rect = hs.geometry.rect(SCREEN_WIDTH/2-width/2, SCREEN_HEIGHT/2-height/2, width, height)
  local wv = hs.webview.new( rect, {}, userscript )
                        :url(url)
                        :allowGestures(true)
                        :windowTitle(name)
                        :allowTextEntry(true)
                        :allowNewWindows(false)
                        :windowStyle({"borderless", "resizable"})
                        :deleteOnClose(true)
                        :userAgent("Mozilla/5.0 (Macintosh; Intel Mac OS X 11_1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.4280.141 Safari/537.36")
                        :show()
  return wv
end