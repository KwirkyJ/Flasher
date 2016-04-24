local Signal   = require 'signal'
local Button   = require 'lbutton'

local lg = love.graphics



local D = {}

D.enter = function(self, goback)
    self.TIME_UNIT = _G.profile:getTimeUnit()
    self.goBack = goback
    
    self.buttonatlas = self.buttonatlas or _G.atlases.buttons
    self.hotatlas    = self.hotatlas    or _G.atlases.hot
    self.charatlas   = self.charatlas   or _G.atlases.darkchars
    
    self.charquads = self.charquads or _G.quads.chars
    
    local qb = _G.quads.buttons
    self.backbutton = self.backbutton or Button.new(  0,265, qb.back)
    self.stopbutton = self.stopbutton or Button.new(200,265, qb.stop)
    
    self.signal = nil
    self.key = nil
    self.hot = nil
    self.help = true
end

D.receiveClick = function(self, mx, my)
    if self.hot == self.backbutton then
        _G.setMode('main')
    end
end

D.receiveKeypress = function(self, key)
    if key == ' ' then
        --TODO: manual signaling?
        return
    elseif key == 'escape' then
        _G.setMode()
    end
    self.help = false
    for c,_ in pairs(self.charquads) do
        if key == c then
            self.active = key
            self.signal = Signal.Signal(self.TIME_UNIT, key)
            return
        end
    end
end

D.receiveKeyrelease = function(self, key)
    if key == ' ' then
        --TODO: manual signaling?
        return
    end
end

D.update = function(self, dt)
    local mx, my = love.mouse.getPosition()
    self.hot = nil
    if self.backbutton:isMouseOver(mx, my) then
        self.hot = self.backbutton
    end
    
    if self.signal then
        if self.signal:isDone() then
            self.signal = nil
            self.active = nil
        else
            self.signal:update(dt)
        end
    end
end

local function drawButton(self, button)
    lg.setColor(0xff, 0xff, 0xff)
    local img = self.buttonatlas
    if self.hot == button then img = self.hotatlas end
    button:draw(img)
end

D.draw = function(self)
    drawButton(self, self.backbutton)
    
    lg.setColor(0,0,0)
    if self.help then
        lg.print("Press a button on the keyboard to see the signal.", 100, 153)
    end
    
    lg.rectangle("fill", 0, 0, 500, 150)
    if self.signal then
        lg.setColor(0xff, 0xff, 0xff)
        lg.print(self.signal:getMorse(), 30, 55)
        if self.signal:isOn() then
            lg.circle("fill", 250, 75, 44)
        end
        
        lg.draw(self.charatlas, self.charquads[self.active], 223, 166)
    end
    
end

return D

