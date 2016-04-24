local Button = require 'lbutton'

local love = _G.love
local lg = love.graphics
local lm = love.mouse
local lw = love.window

local PAUSE_IMAGE = lg.newImage('assets/pausebadge.png')



---Construct buttons
-- @returns table-array of Buttons: {resume, quit}
local makeButtons = function()
    local bq = _G.quads.buttons
    local win_h = lw.getHeight()
    return {resume = Button.new(0,       0, bq.resume),
            quit   = Button.new(0,win_h-35, bq.quit)}
end

---Get which button, if any, has the mouse over its region
-- @param mx x-coordinate
-- @param my y-coordinate
-- @return 'resume', 'quit', or nil
local getHot = function(self, mx, my)
    local hot
    if self.buttons.resume:isMouseOver(mx, my) then
        hot = 'resume'
    elseif self.buttons.quit:isMouseOver(mx, my) then
        hot = 'quit'
    end
    return hot
end

---Routine to draw itself;
--   handles button mouse-over internally, pre-empting update()
local draw = function(self)
    local winw, winh = lw.getDimensions()
    lg.setColor(0xff, 0xff, 0xff, 0x6c)
    lg.rectangle("fill", 0,0, winw,winh)
    
    lg.setColor(0xff, 0xff, 0xff)
    local imgw, imgh = PAUSE_IMAGE:getDimensions()
    lg.draw(PAUSE_IMAGE, math.floor((winw - imgw)/2),
                         math.floor((winh - imgh)/2))
    
    local mx, my = lm.getPosition()
    for _,b in pairs(self.buttons) do
        if b:isMouseOver(mx, my) then
            b:draw(_G.atlases.hot)
        else
            b:draw(_G.atlases.buttons)
        end
    end
end



---Constructor routine
local new = function()
    assert (PAUSE_IMAGE, "pause image/badge must exist")
    return {buttons = makeButtons(),
            getHot = getHot,
            draw   = draw,
           }
end

return {new = new}

