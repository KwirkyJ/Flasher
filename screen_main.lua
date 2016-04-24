local Button = require 'lbutton'

local love = love or _G["love"]
local lg = love.graphics
local lm = love.mouse

local Prime = {}

local function makeButtons()
    local qb = _G.quads.buttons
    local b = {}
    b.lessons      = Button.new(129, 10, qb.learn)
    b.tetrisselect = Button.new(129, 65, qb.play)
    b.dictionary   = Button.new(129,145, qb.dictionary)
    b.settings     = Button.new(129,200, qb.settings)
    b.about        = Button.new(259,260, qb.about)
    b.quit         = Button.new(141,260, qb.quit)
    return b
end

Prime.enter = function(self)
    self.buttons = self.buttons or makeButtons()
end

Prime.receiveClick = function(self, x, y)
    local h = self.hot
    if h == nil then
        return
    elseif h == 'quit' then
        love.event.push('quit')
    else
        _G.setMode(h)
    end
end

Prime.update = function(self, dt)
    local mx, my = lm.getPosition()
    for k,b in pairs(self.buttons) do
        if b:isMouseOver(mx, my) then 
            self.hot = k
            return
        end
    end
    self.hot = nil
end

Prime.draw = function(self)
    local atlases = _G.atlases
    lg.setColor(0xff,0xff,0xff)
    for k,b in pairs(self.buttons) do
        if k == self.hot then
            b:draw(atlases.hot)
        else
            b:draw(atlases.buttons)
        end
    end
    
    --lg.setColor(0,0,0)
    --lg.print("saves at: "..love.filesystem.getSaveDirectory(), 5, 5)
end

return Prime

