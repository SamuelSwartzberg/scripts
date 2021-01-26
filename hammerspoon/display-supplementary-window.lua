globals = require("globals")

function create_new_supplementary_window(text, width, height)
  rect=hs.geometry.rect(
    SCREEN_WIDTH-(width+50),
    50,
    width,
    height
  )
  canvas=hs.canvas.new(rect)
  canvas:appendElements({
    type="rectangle", 
    action="fill",
    roundedRectRadii={ xRadius = 20, yRadius = 20 },
    fillColor={black=0.8}
  }):appendElements({
    type="text", 
    text=text,
    textSize=16,
    frame={x=20, y=20, h=height-40, w=width-40}
  }):alpha(0.8):show()
  hs.timer.doAfter(10, function()
    canvas:delete(0.5)
  end)
end