local Button    = require 'lbutton'
local Skillpane = require 'skillpane'

local lg = love.graphics

local L = {}

local makeButtons = function(lesson_count)
    local bs = {back     = Button.new(  0,265, _G.quads.buttons.back),
                practice = Button.new(386,105, _G.quads.buttons.practice)
               }
    for i=1, lesson_count do
        bs[i] = Button.new(110, (i-1)*40 + 11, _G.quads.buttons.arrow)
    end
    return bs
end

L.enter = function(self)
    self.profile = _G.profile
    
    local ranks = self.profile:getSkillRanks()
    self.buttons = makeButtons(#ranks)
    self.skillpane = Skillpane.new(150, 11, ranks)
end

L.receiveKeypress = function(self, key)
    if key == 'escape' then
        _G.setMode()
    --elseif key == 'return' then
    --    practice weak skills
    end
end

L.receiveClick = function(self, x, y)
    if self.hot == 'back' then
        _G.setMode()
    elseif self.hot == 'practice' then
        _G.setMode('lesson')
    else
        if not self.buttons[self.hot] then
            return
        end
        assert (type(self.hot) == 'number')
        _G.lessonLevel = self.hot
        _G.setMode('lesson')
    end
end

L.update = function(self, dt)
    self.hot = nil
    local mx, my = love.mouse.getPosition()
    for k,b in pairs(self.buttons) do
        if b:isMouseOver(mx, my) then
            self.hot = k
            return
        end
    end
    
    local skillOver = self.skillpane:getMousedOverElem(mx, my)
    if skillOver then
        self.hot = skillOver
    end
end

L.draw = function(self)
    lg.setColor(0xff, 0xff, 0xff)
    local buttonAtlas = _G.atlases.buttons
    local hotAtlas    = _G.atlases.hot
    
    for k,b in pairs(self.buttons) do
        if self.hot == k then
            b:draw(hotAtlas)
        else
            b:draw(buttonAtlas)
        end
    end
    
    self.skillpane:draw()
end

return L

