local Button    = require 'lbutton'
local RadioB    = require 'lradiobutton'
local Skillpane = require 'skillpane'



local MIN_AUTOSELECT_STRENGTH = 4



local function makeButtons(ranks)
    local t = {back = Button.new(0,
                                 love.window.getHeight() - 35, 
                                 _G.quads.buttons.back),
               signals = Button.new(love.window.getWidth() - 110,
                                    100, 
                                    _G.quads.buttons.signals),
              }
    for i=1, #ranks do
        local b = RadioB.new(110, (i-1)*40 + 15, 
                             _G.quads.buttons.box_unselected,
                             _G.quads.buttons.box_selected)
        if ranks[i] >= MIN_AUTOSELECT_STRENGTH then
            b:toggle()
        end
        t[i] = b
    end
    return t
end



local P = {}

P.enter = function(self)
    local ranks = _G.profile:getSkillRanks()
    self.buttons = self.buttons or makeButtons(ranks)
    self.skillpane = Skillpane.new(150,11, ranks)
end

P.receiveClick = function(self, mx, my)
    if not self.hot then return end
    if self.hot == 'back' then 
        _G.setMode()
    elseif type(self.hot) == 'number' then
        local b = self.buttons[self.hot]
        assert(b)
        b:toggle()
    elseif self.hot == 'signals' then
        local opts = {}
        for i=1, #self.buttons do
            opts[i] = self.buttons[i]:isSelected()
        end
        _G.tetrisOpts = opts
        _G.setMode('tetrisplay')
    end
end

P.receiveKeypress = function(self, key)
    if key == 'escape' then
        _G.setMode()
    end
end

P.update = function(self, dt)
    local hot
    local mx, my = love.mouse.getPosition()
    for k,b in pairs(self.buttons) do
        if b:isMouseOver(mx,my) then
            hot = k
            break
        end
    end
    self.hot = hot or self.skillpane:getMousedOverElem(mx, my)
end

P.draw = function(self)
    love.graphics.setColor(0xff, 0xff, 0xff)
    local batlas = _G.atlases.buttons
    local hatlas = _G.atlases.hot
    for k,b in pairs(self.buttons) do
        if self.hot == k then
            b:draw(hatlas)
        else
            b:draw(batlas)
        end
    end
    self.skillpane:draw()
end



return P

