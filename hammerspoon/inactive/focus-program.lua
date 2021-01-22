function focus_program(name, path)
  application = hs.application.find(name)
  if application then 
    window = application:mainWindow()
    if window then
      window:focus()
    else
      hs.application.open(path)
    end  
  else
    hs.application.open(path)
  end  
end

function bind_focus_program(modifiers, key, name, path)
  hs.hotkey.bind(modifiers, key, function()
    focus_program(name,path)
  end)
end