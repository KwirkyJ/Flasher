local Signal = require 'signal'



---Self-evident.
-- @return boolean; false if 'between signals'.
local isOn = function(self)
    if self.signal then
        return self.signal:isOn() 
    end
    return false
end

---Self-evident.
-- @return string.
local getMessage = function(self)
    return self[1]
end

---Get the morse string representation.
-- @return string.
local getMorse = function(self)
    return Signal.fromMessage(self[1])
end

---Utility routine to manually set the delay between 'loops'.
-- @param ms number in milliseconds for delay between loops;
--           raises error if number < 0 (default self[2] (time_unit))
local setDelay = function(self, ms)
    ms = ms or self[2]
    assert(type(ms) == 'number', 'delay unit must be number')
    assert(ms >= 0, 'delay unit must not be negative')
    self[3] = ms / 1000
end

---Activates the looper; if not called explicitly, it will wait the
-- duration of the delay unit (self[3]) as passed via update(dt) before
-- first pulse.
local start = function(self)
    self.delay = nil
    self.signal = Signal.new(self[2], self[1])
end

---Advance the looper's perception of time by a delta.
-- @param dt positive number.
local update = function(self, dt)
    local s = self.signal
    if s then
        if s:isDone() then
            self.signal = nil
            self.delay = self[3]
        else
            s:update(dt)
        end
    else
        self.delay = (self.delay or self[3]) - dt
        if self.delay <= 0 then
            self:start()
        end
    end
end



local function new(ms, msg)
    assert(type(ms) == 'number', 'time unit must be a number')
    assert(ms > 0, 'time unit must be > 0')
    assert(type(msg) == 'string', 'message must be a string')
    
    return {msg, -- message
            ms,  -- time_unit
            ms/1000,  -- delay_unit
            start      = start,
            setDelay   = setDelay,
            update     = update,
            isOn       = isOn,
            getMessage = getMessage,
            getMorse   = getMorse,
           }
end

return {new = new}

