globals = require("globals")

function debug_table(table)
  for key, val in pairs(table) do 
    print(key)
    print(val)
  end
end

focusapplication = {}

function set_half(name, path, side)
  xcoord = 0
  if side=="right" then 
    xcoord= SCREEN_WIDTH/2
  end
  print(name, path, side)
  application = hs.application.find(name)
  if application then 
    print("appl")
    print(application)
    window = application:mainWindow()
    if window then
      window:focus():setSize({w = SCREEN_WIDTH/2, h = SCREEN_HEIGHT}):setTopLeft(hs.geometry({x=xcoord,y=0}))
      return application
    else
      return hs.application.open(path, 10, true)
    end  
  else
    return hs.application.open(path, 10, true)
  end 
end

function set_layout(app1, app2)
  focusapplication.left = set_half(app1.name, app1.path, "left")
  focusapplication.right = set_half(app2.name, app2.path, "right")
end

function setFullscreen()
  hs.window.frontmostWindow():setSize({w = SCREEN_WIDTH, h = SCREEN_HEIGHT}):setTopLeft(hs.geometry({x=0,y=0}))
end

function switchFocusLRwindow()
  debug_table(focusapplication)
  if not (focusapplication and focusapplication.left and focusapplication.right and focusapplication.left:mainWindow() and  focusapplication.right:mainWindow()) then
    print("nothing to focus")
    return
  end
  if focusapplication.left == hs.application.frontmostApplication() then
    print("focusing right")
    focusapplication.right:mainWindow():focus()
  else 
    print("focusing left")
    focusapplication.left:mainWindow():focus()
  end
end