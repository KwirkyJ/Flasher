local Dict = require 'dict'

--local unpack = unpack or table.unpack

local S = {}


--===================


-- from PiL2 20.4
local function trim(s)
  return (s:gsub("^%s*(.-)%s*$", "%1"))
end

assert(trim'' == '')
assert(trim' ' == '')
assert(trim'  ' == '')
assert(trim'a' == 'a')
assert(trim' a' == 'a')
assert(trim'a ' == 'a')
assert(trim' a ' == 'a')
assert(trim'  a  ' == 'a')
assert(trim'  ab cd  ' == 'ab cd')
assert(trim' \t\r\n\f\va\000b \r\t\n\f\v' == 'a\000b')


--==================


--generate a morse string from standard characters (assumes trimmed message)
S.fromMessage = function(msg)
    local morse = ''
    for i=1, string.len(msg) do
        local c = string.sub(msg, i, i)
        if c == ' ' then
            -- can get away with this because msg never starts with a space
            morse = string.sub(morse, 1, -2) .. '\t'
        else
            local m = Dict[c]
            if not m then 
                error ("morse pattern not known for : "..c)
            end
            morse = morse .. m .. ' '
        end
    end
    return trim(morse)
end

-- not used in this code
---generate text from morse string (assumes trimmed message)
S.fromMorse = function(morse)
    local buf = ''
    local msg = ''
    local morselen = string.len(morse)
    for i=1, morselen do
        local elem = string.sub(morse, i, i)
        if elem == '.' or elem == '-' then
            buf = buf .. elem
        end
        if elem == ' ' or elem == '\t' or i == morselen then
            for char, code in pairs(Dict) do
                if buf == code then
                    msg = msg .. char
                    buf = ''
                    break
                end
            end
            if buf ~= '' then
                -- do what when the code is not found in the dictionary?
                error('code not found: '..buf)
            end
            if elem == '\t' then -- opposed to a space
                msg = msg .. ' '
            end
        end
    end
    return msg  
end


-- ========================


---Compute the time unit of this sequence as best as able.
local function computeTimeUnit(self)
    local ps = self.seq
    if #ps < 1 then return '' end

    local intervals = self:getIntervals()
    
    -- MATH the intervals for meaning
    --guess the time unit
    -- possible relations : {1/7, 1/3, 3/7, 1, 7/3, 3, 7}
    --            -> shortest, shorter, short, same, long, longer, longest
    
    local guess_acc_on = 0
    local guesses_on   = 0
    
    for i=1, #intervals, 2 do
        local this = intervals[i]
        assert(this[1] == 'on')
        for j=1, #intervals, 2 do
            local that = intervals[j]
            local ratio = this[2] / that[2]
            local duration = this[2]
            if ratio < 2/3 then 
                this[3] = 'shorter'
            elseif ratio > 2 then 
                this[3] = 'longer'
                duration = duration / 3
            else 
                this[3] = 'same'
                if guesses_on < 1 then -- not enough data to compare
                    duration = 0
                    guesses_on = guesses_on - 1
                else
                    if duration > ((guess_acc_on / guesses_on) * 2) then
                        -- greater than twice the 'guessed time unit
                        -- assume 'long'
                        duration = duration / 3
                    end
                end
            end
            guess_acc_on = guess_acc_on + duration
            guesses_on = guesses_on + 1
        end
    end
    
    if guesses_on < 1 then -- all nearly equal-interval pulses: ....s or ----s
        assert (guess_acc_on == 0)
        for _,i in ipairs(intervals) do
            if i[1] == 'on' then
                assert (i[3] == 'same')
                guess_acc_on = guess_acc_on + i[2]
                guesses_on = guesses_on + 1
            end
        end
    end
    local guess_tu_on = guess_acc_on / guesses_on
    
    
    local guess_acc_off = 0
    local guesses_off   = 0
    
    if #intervals > 1 then -- exists at least one break
    for i=2, #intervals, 2 do
        local this = intervals[i]
        assert (this[1] == 'off')
        for j=2, #intervals, 2 do
            local that = intervals[j]
            local ratio = this[2] / that[2]
            local duration = this[2]
            if ratio < (1/7 + 1/3) / 2 then
                this[3] = 'shortest'
            elseif ratio < (1/3 + 3/7) / 2 then
                this[3] = 'shorter'
            elseif ratio < (3/7 + 1) / 2 then
                this[3] = 'short'
                duration = duration / 3
            elseif ratio > (7 + 3) / 2 then
                this[3] = 'longest'
                duration = duration / 7
            elseif ratio > (3 + 7/3) / 2 then     
                this[3] = 'longer'
                duration = duration / 3
            elseif ratio > (7/3 + 1) / 2 then
                this[3] = 'long'
                duration = duration / (7/3)
            else
                this[3] = 'same'
                if guesses_off < 1 then -- not enough data
                    duration = 0
                    guesses_off = guesses_off - 1
                --else
                -- ?
                end
            end
            guess_acc_off = guess_acc_off + duration
            guesses_off = guesses_off + 1
        end
    end
    end -- #intervals > 1
    
    if guesses_off < 1 then -- all equal(ish)-interval breaks
        assert (guess_acc_off == 0)
        for _,i in ipairs(intervals) do
            if i[1] == 'off' then
                assert (i[3] == 'same')
                guess_acc_off = guess_acc_off + i[2]
                guesses_off = guesses_off + 1
            end
        end
    end
    local guess_tu_off = guess_acc_off / guesses_off
    
    
    local ratio = guess_tu_on / guess_tu_off
    if ratio < (1/7 + 1/3) / 2 then
        guess_tu_off = guess_tu_off / 7
    elseif ratio < (1/3 + 3/7) / 2 then
        guess_tu_off = guess_tu_off / 3
    elseif ratio < (3/7 + 1) / 2 then
        guess_tu_on = guess_tu_on / 3
        guess_tu_off = guess_tu_off / 7
    elseif ratio > (7 + 1) / 2 then  -- impossible?
        guess_tu_on = guess_tu_on / 7
    elseif ratio > (3 + 7/3) / 2 then
        guess_tu_on = guess_tu_on / 3
    elseif ratio > (7/3 + 1) / 2 then
        guess_tu_on = guess_tu_on / 7
        guess_tu_off = guess_tu_off / 3
    --else
    -- 'same'
    end
    
    
    -- finally, the calculated time-unit!
    return (guess_tu_on + guess_tu_off) / 2
end


---Determine whether the signal is 'on' at a given time.
-- @param self This PulseSeq 'object'.
-- @param t    Positive number, time since 'start' of sequence. 
-- @returns True iff t is between (inclusive) 
--          start and start+duration of a pulse.
local function isPulseSeqOn(self, t)
    -- linear search -> possible performance issue
    for _,pulse in ipairs(self.seq) do
        if  t >= pulse[1]
        and t <= pulse[1] + pulse[2] 
        then
            return true
        end
    end
    return false
end

---Determine whether the sequence is completed at a given time.
-- @param self This PulseSeq 'object'.
-- @param t    Positive number, time since 'start' of sequence.
-- @returns True iff t is greater than starttime+duration of last pulse.
local function isPulseSeqDone(self, t)
    local lastPulse = self.seq[#self.seq]
    if not lastPulse then return true end -- empty sequence
    return t > (lastPulse[1] + lastPulse[2])
end

---Add a pulse to the sequence.
-- @param self     This PulseSeq 'object'.
-- @param start    Positive number, starttime of the pulse.
-- @param duration Positive number, duration of the pulse.
-- @returns Nothing; raises error if self:isDone(start).
local function addPulseToSeq(self, start, duration)
    local err
    --assert (start >= 0)
    --assert (duration > 0)
    if not self:isDone(start) then
        err = "cannot add a pulse into a live region of the sequence"
    elseif duration <= 0 then
        err = "pulse duration must be greater than zero"
    elseif start < 0 then
        err = "pulse cannot start at time less than zero"
    end
    if err then error(err) end
    table.insert(self.seq, {start, duration})
end

---Convert a formatted morse string into a list of pulses {start, duration}
local function toPulses(time_unit, morse)
    local seq = {}
    morse = morse or ''
    local units = 0
    for i=1, string.len(morse) do
        local elem = string.sub(morse, i, i)
        if elem == '.' then
            table.insert(seq, {time_unit*units, time_unit})
            units = units + 2 -- 1+1
        elseif elem == '-' then
            table.insert(seq, {time_unit*units, time_unit*3})
            units = units + 4 --3+1
        elseif elem == ' ' then
            -- break between letters
            units = units + 2 -- 3-1
        elseif elem == '\t' then
            -- break between words
            units = units + 6 -- 77-1
        end
    end
    return seq
end

---Constructor of a PulseSeq 'object'.
-- @param time_unit Positive number
-- @param morse_str Formatted morse string to convert into pulses. (Optional)
-- @returns Table comprising a new 'object'.
local function makePulseSeq(time_unit, morse_str)
    local P = {seq = toPulses(time_unit, morse_str),
               time_unit = time_unit}
    P.isOn   = isPulseSeqOn
    P.isDone = isPulseSeqDone
    P.addPulse = addPulseToSeq
    P.getSeq   = function(self) return self.seq end
    
    -- make intervals in-order list of {off/on; duration}
    P.getIntervals = function(self)
        local intervals = {}
        for i, pulse in ipairs(self.seq) do
            table.insert(intervals, {'on', pulse[2]})
            local next_p = self.seq[i+1]
            if next_p then
                table.insert(intervals, 
                             {'off', next_p[1] - (pulse[1] + pulse[2])})
            end
        end
        return intervals
    end
    P.getMorse = function(self)
        local TU = self.time_unit 
--        local TU = self:computeTimeUnit()
        local morse = ''
        for _, interval in ipairs(self:getIntervals()) do
            local symbol
            if interval[1] == 'on' then
                if interval[2] >= 2*TU then
                    symbol = '-'
                else
                    symbol = '.'
                end
            else
                if interval[2] < 2*TU then 
                    symbol = '' -- add nothing
                elseif interval[2] < 5*TU then
                    symbol = ' '
                else
                    symbol = '/t'
                end
            end
            morse = morse .. symbol
        end
        return morse, TU
    end
    P.computeTimeUnit = computeTimeUnit
    
    return P
end

S._PulseSeq = makePulseSeq


-- =====================


---'Object' to build a message from received pulses.
-- @param time_unit_ms Positive number for expected time-unit.
-- @returns Listener.
S.Listener = function(time_unit_ms)
    local l = {tu = time_unit_ms / 1000,
               t_on = -1,
               pulses = S._PulseSeq(time_unit_ms / 1000)
              }
    
    ---Inform Listener that the signal was turned on at this time;
    -- raises error if t is negative or would overlap with existing sequence.
    -- Sequential calls without an intervening signalOff() will be ignored.
    -- @param self This Listener.
    -- @param t    Positive number.
    l.signalOn = function(self, t)
        assert (t >= 0)
        if next(self.pulses:getSeq()) then -- not empty
            assert (self.pulses:isDone(t))
        end
        if self.t_on < 0 then
            self.t_on = t
        end
    end
    
    ---Inform Listener that the signal was turned off at this time;
    -- raises error if signalOn has not been called prior;
    -- raises error if provided time is not greater than matching signalOn;
    -- raises error if resulting pulse would overlap with existing sequence.
    -- @param self This Listener.
    -- @param t    Positive number.
    l.signalOff = function(self, t)
        self.pulses:addPulse(self.t_on, t - self.t_on)
        self.t_on = -1
    end
    
    ---Time index of the end of last pulse/event to be received.
    -- @param self This Listener.
    -- @return Time of 'end' of signal; 
    --         nil iff no completed pulses (no signalOn/singalOff pair).
    l.getLastEvent = function(self)
        local events = self.pulses:getSeq()
        if not events or #events < 1 then return nil end
        return events[#events][1] + events[#events][2]
    end
    
    ---Get the formatted morse string represented by the signals received.
    l.getMorse = function(self)
        return self.pulses:getMorse()
    end
    
    return l
end


-- ======================


---Signal 'object' to handle a transmitting signal;
-- data is immutable; time passage is abstracted through calls to update(dt).
-- @param time_unit_ms Positive number in milliseconds of a single 'time unit'.
-- @param message      Message to be signalled (lower-case alphanumerics).
-- @return Signal table/object.
local function Signal(time_unit_ms, message)
    assert (type(time_unit_ms) == 'number')
    assert (type(message) == 'string') -- must be string
    
    message = trim(message)
    local tu = time_unit_ms / 1000
    
    local s = {tu       = tu,
               message  = message,
               morse    = S.fromMessage(message),
               pulses   = makePulseSeq(tu, S.fromMessage(message)),
               progress = 0,
              }
    s.update = function(self, dt)
        -- known 'bug': high dt or tiny time-units can skip pulses/breaks
        self.progress = self.progress + dt
    end
    s.isOn       = function(self) return self.pulses:isOn(self.progress) end
    s.isDone     = function(self) return self.pulses:isDone(self.progress) end
    s.getMessage = function(self) return self.message end
    s.getMorse   = function(self) return self.morse end
    return s
end

S.new = Signal
S.Signal = Signal


return S
