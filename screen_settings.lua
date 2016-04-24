local Button = require 'lbutton'
local Looper = require 'looping_signal'

local lw = love.window
local lg = love.graphics
local lm = love.mouse


local msgs = {'mars', 'tough', 'hello', 'marzipan', 'telegram', 'camelot'}


---requires that x already be normalized
local function calcTimeUnit(x)
    --return math.floor(x^2 / 250 + 20)
    return x + 50
end

local function getSliderHandleOffset(t)
    --return math.floor(((t-20) * 250) ^ 0.5)
    return math.floor(t-50)
end

local function startNewSignal(self)
    local msg = msgs[math.random(#msgs)]
    self.signal = Looper.new(self.profile:getTimeUnit(), msg)
    self.signal:setDelay(self.profile:getTimeUnit()*7)
    self.signal:start()
end



local SET = {speedSliderBand   = {100, 100, 200, 10}}

SET.getTimeUnit = function(self)
    return self.profile:getTimeUnit()
end

local buildButtons = function()
    local qb = _G.quads.buttons
    local back = Button.new(0,lw.getHeight()-35,  qb.back)
--    local reset = Button.new(340,200, qb.box_selected)
    local handle = Button.new( 0, 95, qb.box_unselected)
    return {back = back, reset = reset, handle = handle}
end

SET.enter = function(self)
    self.profile = _G.profile
    self.buttonatlas = self.buttonatlas or _G.atlases.buttons
    self.hotatlas    = self.hotatlas    or _G.atlases.hot
    self.hot = nil
    
    self.buttons = self.buttons or buildButtons()
    
    self.isSliderLive = false
    self.lastMouse = {x=0, y=0,
                      getPos = function(this) return this.x, this.y end,
                      setPos = function(this, x, y) this.x, this.y = x, y end,
                     }
    local handleOff = 200 - getSliderHandleOffset(self.profile:getTimeUnit())
                                + self.speedSliderBand[1] - 8
    
    self.buttons.handle[1] = handleOff
    startNewSignal(self)
end

SET.update = function(self, dt)
    self.hot = nil
    local mx, my = lm.getPosition()
    for k,b in pairs(self.buttons) do
        if b:isMouseOver(mx, my) then
            self.hot = k
            break
        end
    end
    if self.isSliderLive then
        if not lm.isDown('l') then
            self.isSliderLive = false
            self.buttons.handle:setQuad(_G.quads.buttons.box_unselected)
            self.lastMouse:setPos(0,0)
        end
        local mx, my = lm.getPosition()
        mx = math.max(mx, self.speedSliderBand[1])
        mx = math.min(mx, self.speedSliderBand[1] + self.speedSliderBand[3])
        local lx, _ = self.lastMouse:getPos() 
        if not (mx == lx) then
            self.lastMouse:setPos(mx, my)
            self.profile:setTimeUnit(calcTimeUnit(self.speedSliderBand[3] 
                                              - (mx - self.speedSliderBand[1])))
            self.buttons.handle[1] = mx - 10
            
            startNewSignal(self)
        end
    end
    
    
    if not self.signal then
        self:startNewSignal()
    end
    self.signal:update(dt)
end

SET.receiveKeypress = function(self, key)
    if key == 'escape' then
        _G.setMode()
    end
end

SET.receiveClick = function(self, mx, my)
    if self.hot == 'back' then
        self.signal = nil
        _G.setMode()
    elseif self.hot == 'handle' then
        self.buttons.handle:setQuad(_G.quads.buttons.box_selected)
        self.isSliderLive = true
--    elseif self.hot == 'reset' then
--        TODO: profile reset more than single button press
--        self.profile:reset()
    end
end

SET.draw = function(self)
    lg.setColor(0xff, 0xff, 0xff)
    local t = self.speedSliderBand
    lg.rectangle('fill', t[1], t[2], t[3], t[4])
    
    lg.print("" .. self.profile:getTimeUnit() .. "ms", 
             t[1]+t[3]+15, t[2])
    
    local mx, my = lm.getPosition()
    for k,b in pairs(self.buttons) do
        if b:isMouseOver(mx, my) or
           (k == 'handle' and self.isSliderLive) then
            b:draw(self.hotatlas)
        else
            b:draw(self.buttonatlas)
        end
    end
    
    lg.setColor(0,0,0)
--    lg.print("RESET", 300, 200)
    
    lg.rectangle('fill', 400, 100, 40, 40)
    if self.signal and self.signal:isOn() then
        lg.setColor(0xff, 0xff, 0xff)
        lg.circle('fill', 420, 120, 20)
    end
end



return SET

