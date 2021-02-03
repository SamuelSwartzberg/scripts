-- globals = require("globals")
-- debug = require("debug")
-- views = {}






-- function do_for_top_visible_view(callback)
--   return function()
--     view = visible_views[#visible_views]
--     if view then
--       if view:hasContent() and (view.type == "webview" or view:getWindow()) then -- webviews don't mind losing their windows, but applications can't recover
--         if not view.hidden then
--           callback(view)    
--         end
--       else
--         print("deleted nonexistant view")
--         visible_views[#visible_views] = nil
--       end
--     end
--   end
-- end


-- no_hide_timer = hs.timer.doEvery(0.1, do_for_top_visible_view(function(view)
--   view:bringToFront()
-- end))

-- visible_views = {}


-- function get_semipermanent_view(type, name, path, width, height, createfn, hidefn, showfn, visiblefn, tofrontfn, getwindowfn)

--   function create_view(name, path, width, height)
--     return {content =  createfn(name, path, width, height), hidden = false, type = type, name = name}
--   end

--   view = create_view(name, path, width, height)

--   function view:hide()
--     hidefn(self)
--     self.hidden = true
--   end

--   function view:show()
--     showfn(self)
--     self.hidden = false
--   end

--   function view:isVisible()
--     return visiblefn(self)
--   end

--   function view:bringToFront()
--     tofrontfn(self)
--   end

--   function view:hasContent()
--     return not not self.content
--   end

--   function view:getWindow()
--     return getwindowfn(self)
--   end

--   print(view.content)
--   view:show()

--   return view
-- end

-- function get_webview( destructive, name, path, width, height)

--   createfn = function(name, path, width, height)
--     return launch_webview(name, path, width, height)
--   end
  
--   hidefn = function(view)
--     view.content:hide()
--   end
--   if destructive then
--     hidefn = function (view)
--       views[view.name].content:delete()
--       views[view.name] = nil
--     end
--   end
--   showfn = function(view)
--     view.content:show()
--     view:getWindow():focus()
--   end
--   if destructive then
--     show = function (view)
--       print("does nothing")
--     end
--   end
--   visiblefn = function(view)
--     return view.content:isVisible()
--   end
--   tofrontfn = function(view)
--     view.content:bringToFront()
--   end
--   getwindowfn = function(view)
--     return view.content:hswindow()
--   end

--   return get_semipermanent_view("webview", name, path, width, height, createfn, hidefn, showfn, visiblefn, tofrontfn, getwindowfn)

-- end

-- function get_application_view( name, path, width, height)

--   createfn = function(name)
    
--   end 
--   hidefn = function(view)
--     print(#visible_views)
--     for i=1, #visible_views do
      
--       if visible_views[i].name == view.name then
--         visible_views[i]=nil
--       end
--     end
--     view.content:hide()
--   end
--   showfn = function(view)
--     visible_views[#visible_views+1]=view
--     view:getWindow():centerOnScreen():focus()
--   end
--   visiblefn = function(view)
--     return view:getWindow():isVisible()
--   end
--   tofrontfn = function(view)
--     view:getWindow():centerOnScreen():focus()
--   end
--   getwindowfn = function(view)
--     return view.content:mainWindow()
--   end

--   return get_semipermanent_view("application", name, path, width, height, createfn, hidefn, showfn, visiblefn, tofrontfn, getwindowfn)

-- end


-- function get_view(destructive, type, name, location, width, height)
--   if type == "webview" then
--     return get_webview(destructive, name, location, width, height)
--   else 
--     return get_application_view(name, location, width, height)
--   end
-- end


-- function show_hide(view)
--   if view:isVisible() then
--     view:hide()
--   else
--     view:show()
--   end
-- end

function bind_view(destructive, type, modifiers, key, name, location, width, height)
  hs.hotkey.bind(modifiers, key, function()
    -- if views[name] and views[name]:hasContent() and views[name]:getWindow() then
    --   show_hide(views[name])
    -- else 
    --   views[name] = get_view(destructive, type, name, location, width, height)
      
    -- end

    application = hs.application.find(name)
    if not application then 
      hs.application.open(name, 10, true):mainWindow():centerOnScreen()
    elseif application:mainWindow()==hs.window.focusedWindow() then
      application:hide()
    else
      application:mainWindow():centerOnScreen():focus()
    end
  end)
end