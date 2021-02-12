SCREEN_WIDTH = 2560
SCREEN_HEIGHT = 1600

function copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[copy(k, s)] = copy(v, s) end
  return res
end

function createDoKeyOutsideOfApplication(bundleID, callback)
  return function()
    local discord = hs.application.open(bundleID, 10, true)
    discord:activate()
    hs.timer.doAfter(0.1, function()
      callback()
      hs.timer.doAfter(0.1, function()
        discord:hide()
      end)
    end)
  end
end
