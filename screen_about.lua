local Button = require 'lbutton'

local love = love or _G.love
local lg = love.graphics

local About = {}

---Call to 'activate' the about screen
About.enter = function(self)
    self.back = self.back or Button.new(0,265 ,_G.quads.buttons.back)
end

About.update = function(self, dt)
    --<Button>.hot is not a sensitive namespace
    self.back.hot = self.back:isMouseOver(love.mouse.getPosition())
end

About.receiveKeypress = function(self, key)
    if key == 'escape' then
        _G.setMode()
    end
end

About.receiveClick = function(self, x, y)
    if self.back.hot then
        _G.setMode()
    end
end

---Draw the about screen
About.draw = function(self)
    lg.setColor(0, 0, 0)
    lg.print("Tool to learn and hone Morse Code", 60, 80)
    lg.print("(c) 2016 J. 'KwirkyJ' Smith <kwirkyj.smith0@gmail.com>", 60, 95)
    
    lg.setColor(0xff, 0xff, 0xff)
    if self.back.hot then
        self.back:draw(_G.atlases.hot)
    else
        self.back:draw(_G.atlases.buttons)
    end
end

return About

