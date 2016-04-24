local Bubble = require 'ltetrisbubble'

local lg    = love.graphics
local lrand = love.math.random
local floor = math.floor

local SIGNAL_SIZE = 10
local BASE_DROPSPEED = 30
local IN_BUBBLE_LIFE = 1



local function needNewSignal(self)
    --TODO: level adjusts spawn countdown
    if self.time > 2 then
        self.time = self.time - 2
        return true
    end
    return false
end

---Create a new Bubble instance
local function getNewBubble(self)
    --TODO: level augments time-unit?
    --TODO: full-word signals?
    local c = self.chars[lrand(#self.chars)]
    return Bubble.new(c, self.ms, BASE_DROPSPEED)
end

local function getActiveElem(t)
    for i=1, #t do
        if not t[i]._inputgenerated then
            return t[i]
        end
    end
end



local getStats = function(self)
    -- TODO: time to next level (or played?); other?
    return self.level, self.score, self.lives, self.maxlives
end

local rKey = function(self, key)
    local s = getActiveElem(self.bubbles)
    if not s then -- there is no active signal
        return
    end
    --TODO: words in addition to characters
    local msg = s:getMessage()
    local inputbubble
    if key == msg then -- correct!
        self.score = self.score + 1 --TODO? bonus with level, speed
        table.remove(self.bubbles, 1)
        --TODO? correct/incorrect rewarded the profile
        inputbubble = Bubble.new(key,nil,-BASE_DROPSPEED,IN_BUBBLE_LIFE)
    else -- incorrect
        inputbubble = Bubble.new(key,nil,BASE_DROPSPEED*2,IN_BUBBLE_LIFE)
        inputbubble._bad = true -- TODO: make abstract this flag
    end
    assert (inputbubble, 'bubble must exist')
    inputbubble:setPosition(s:getPosition())
    inputbubble._inputgenerated = true --TODO: make abstract this flag
    self.bubbles[#self.bubbles + 1] = inputbubble
end

---receivePulse(duration) For manual signaling
--local rPl = function(self, duration)
--    return
--end

local function updateSignals(self, dt)
    -- reverse order; may remove elements from list
    for i=#self.bubbles,1, -1 do
        local b = self.bubbles[i]
        
        b:update(dt)
        
        local _,drop = b:getPosition()
        if drop > (self.h - SIGNAL_SIZE) or 
           not b:isAlive() then
            if not b._inputgenerated then
                self.lives = self.lives - 1
            end
            table.remove(self.bubbles, i)
        end
    end
end

local update = function(self, dt)
    if self.lives < 0 then -- TODO: results?
        _G.setMode('tetrisselect') -- return
    end
    self.time = self.time + dt
    if needNewSignal(self) then
        local b, x = getNewBubble(self), lrand(self.w - SIGNAL_SIZE)
        b:setPosition(x)
        self.bubbles[#self.bubbles + 1] = b
    end
    updateSignals(self, dt)
end

--TODO? make bubbles smart enough to draw themselves
local function drawBubble(b)
    local x, y = b:getPosition()
    lg.setColor(0x30, 0x30, 0x30)
    if b._inputgenerated then -- a 'word' bubble (for now)
        local progress = (1 - b:getLifeProgress())
        if b._bad then
            lg.setColor(0xff*progress, 0, 0)
        else
            lg.setColor(0xff*progress, 0xff*progress, 0xff*progress)
        end
        lg.print(b:getMessage(), b:getPosition())
    else
        if b:isOn() then lg.setColor(0xff, 0xff, 0xff) end
        lg.rectangle('fill', x,floor(y), SIGNAL_SIZE,SIGNAL_SIZE)
    end
end

local draw = function(self, ulx, uly)
    lg.push()
    lg.translate(ulx or 0, uly or 0)
    lg.setColor(0,0,0)
    lg.rectangle('fill', 0,0, self.w,self.h)
    for i=1, #self.bubbles do
        drawBubble(self.bubbles[i])
    end
    --for _,b in ipairs(self.bubbles) do
    --    b:draw()
    --end
    lg.pop()
end



local new = function(width, height, ms, chars)
--    debug the character set
    local str = ''
    for _,c in ipairs(chars) do
        str = str .. c .. ','
    end
    print('starting with ' .. str)

    if (not chars) or 
       (type(chars) ~= 'table') or 
       (#chars < 1)
    then
        error("character table must not be empty")
    end
    return {bubbles  = {},
            level    = 1,
            ms       = ms,
            lives    = 4,
            maxlives = 6,
            score    = 0,
            time     = 0, -- seconds since 'start'
            w        = width,
            h        = height,
            chars    = chars,
            --
            draw         = draw,
            update       = update,
            receiveKey   = rKey,
--            receivePulse = rPl,
            getStats     = getStats,}
end

return {new = new}


