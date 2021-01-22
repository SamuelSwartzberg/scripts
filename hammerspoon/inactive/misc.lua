function do_for_all_visible_views(callback)
  return function()
    for key, view in pairs(visible_views) do 
      if view then
        if view:hasContent() and (view.type == "webview" or view:getWindow()) then -- webviews don't mind losing their windows, but applications can't recover
          if not view.hidden then
            callback(view)    
          end
        else
          print("deleted nonexistant view")
          views[key] = nil
        end
      end
    end
  end
end

function hide_all_others()
  for key, val in pairs(views) do 
    val:hide()
  end
end