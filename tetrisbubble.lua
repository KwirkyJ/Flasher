local Looper = require 'looping_signal'



local KINDS = {'signal', 'word', 'listener'}
local DEFAULT_DROPSPEED = 1
local LOOP_DELAY_FACTOR = 7



---(Bubble):isAlive()
-- @return boolean; whether the entity has outlasted its lifetime
local isAlive = function(self)
    return self[6] > self[7]
end

---(Bubble):isOn()
-- @return boolean
local isOn = function(self)
    if self[4] == KINDS[2] then return true end
    if self.elem.isOn then return self.elem:isOn() end
    return false
end

---(Bubble):getLifeProgress()
-- @return number >= 0; fraction of lifetime spent
--         (0 at start, 1 at 'death'; can be > 1)
local getLifeProgress = function(self)
    return self[7] / self[6]
end

---(Bubble):getMessage()
-- @return string; supplied message, if any (can be nil)
local getMessage = function(self)
    return self[3]
end

---(Bubble):getPosition()
-- @return x,y position
local getPosition = function(self)
    return self[1], self[2]
end

---(Bubble):getType()
-- @return string; enum of bubble kind (signal, word, &.)
local getType = function(self)
    return self[4]
end

---(Bubble):setPosition(x,y)
-- @param x number (default 0)
-- @param y number (default 0)
local setPosition = function(self, x, y)
    self[1] = x or 0
    self[2] = y or 0
end

---(Bubble):update(dt)
-- @param dt 'delta time' (positive number)
local update = function(self, dt)
    self[2] = self[2] + self[5] * dt
    self[7] = self[7] + dt
    if self.elem and self.elem.update then
        self.elem:update(dt)
    end
end



---Bubble.new(msg, time_unit, speed, life)
-- @param msg   string; can cause errors if characters 
--                are not found in a dictionary elsewhere
-- @param tums  positive number; time unit of the signal/listener
--                in milliseconds
-- @param speed number; drop rate in pixels/second; < 0 rises (default 1)
-- @param life  positive number; lifespan in seconds (default +infinity)
-- @return A new 'Bubble' object;
--         msg,nil -> 'word' kind
--         nil,ms  -> 'listener' kind (NOT YET IMPLEMENTED)
--         msg,ms  -> 'signal' kind
--         nil,nil -> error
local function new(msg, tums, speed, life)
    speed = speed or 1
    life = life or math.huge
    
    if msg then
        assert (type(msg) == 'string', 'msg must be a string')
    end
    assert (type(speed) == 'number', 'dropspeed must be a number')
    assert (type(life) == 'number',  'lifetime must be a number')
    assert (life > 0, 'lifetime must be greater than zero')
    
    local kind = KINDS[2] -- 'word'
    local elem
    if tums then
        assert (type(tums) == 'number', 'time unit must be a number')
        assert (tums > 0, 'time unit must be greater than zero')
        if msg then
            kind = KINDS[1] -- 'signal'
            elem = Looper.new(tums, msg)
            elem:setDelay(tums * LOOP_DELAY_FACTOR)
            elem:start()
--        else
--            kind = KINDS[3] -- 'listener'
        end
    else
        if not msg then
            error('must provide at least one of message or time unit')
        end
        -- else: default of word kind
    end
    
    return {[1] = 0,     -- x coord
            [2] = 0,     -- y coord
            [3] = msg,   -- message
            [4] = kind,  -- enum
            [5] = speed, -- drop rate
            [6] = life,  -- fixed lifetime
            [7] = 0,     -- time alive
            elem = elem,
            isAlive         = isAlive,
            isOn            = isOn,
            getLifeProgress = getLifeProgress,
            getMessage      = getMessage,
            getPosition     = getPosition,
            getType         = getType,
            setPosition     = setPosition,
            update          = update,
           }
end



return {new = new}

