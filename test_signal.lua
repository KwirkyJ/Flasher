Signal  = require 'signal'

LuaUnit = require 'luaunit.luaunit'
local fail = assertFail -- from LuaUnit

local time_unit_ms = 100 -- -> 0.1
-- 1/60 -> 0.0166667

TestConversion = {}
TestConversion.test_conversion = function(self)
    local s = 'to be or not to be'
    local m = '- ---\t-... .\t--- .-.\t-. --- -\t- ---\t-... .'
    assertEquals(Signal.fromMessage(s), m)
    assertEquals(Signal.fromMorse(m), s)
    
    assertError(Signal.fromMessage, '$')
    assertError(Signal.fromMorse, '-------')
end

TestSignal = {}
TestSignal.test_single_word = function(self)
    local s = Signal.Signal(time_unit_ms, 'go')
    assertEquals(s:getMessage(), 'go')
    assertEquals(s:getMorse(), '--. ---')
    --0-0.3; 0.4-0.7; 0.8-0.9; 1.2-1.5; 1.6-1.9; 2.0-2.3
    
    -- in first letter-gap
    s:update(1.0)
    assert(not s:isOn())
    assert(not s:isDone())
    
    -- in last dash of last letter
    s:update(1.0)
    assert(s:isOn())
    assert(not s:isDone())
    
    -- well-past
    s:update(1.0)
    assert(not s:isOn())
    assert(s:isDone())
end
TestSignal.test_multiword = function(self)
    local s = Signal.new(time_unit_ms, 'en o')
    assertEquals(s:getMorse(), '. -.\t---')
    --0-0.1; 0.4-0.7; 0.8-0.9; 1.6-1.9; 2.0-2.3; 2.4-2.7
    
    -- in dot of 'n'
    s:update(0.85)
    assert(s:isOn())
    
    -- in first dash of 'o'
    s:update(0.85)
    assert(s:isOn())
    
    -- in last dash of 'o'
    s:update(0.85)
    assert(s:isOn())
    assert(not s:isDone())
    
    s:update(0.85)
    assert(s:isDone())
    assert(not s:isOn())
    
end
TestSignal.test_empty = function(self)
    local s = Signal.Signal(100, '') -- note alias
    assert(not s:isOn())
    assert(s:isDone())
end
TestSignal.test_degenerate = function(self)
    assertError(Signal.new, '')
    assertError(Signal.new, 5)
    assertError(Signal.new, {})
    assertError(Signal.new, nil, 'e')
    assertError(Signal.new, 'e', nil)
    assertError(Signal.new, '3', 'e')
    assertError(Signal.new, 'e', 'three')
    assertError(Signal.new, 'e', {})
end



TestListener = {}
TestListener.setUp = function(self)
    self.l = Signal.Listener(100)
    self.l:signalOn(0) -- 0 stand-in for "love.timer.getTime()" at creation
end
TestListener.test_first_instants = function (self)
    assertEquals(self.l:getMorse(), '')
    self.l:signalOff(7/60) -- ~0.116667
    assertEquals(self.l:getMorse(), '.')
end
TestListener.test_signalOn_uninterrupted = function(self)
    self.l:signalOn(0.2)
    self.l:signalOff(0.3)
    assertEquals(self.l:getMorse(), '-')
end
TestListener.test_signalOn_overlap = function(self)
    self.l:signalOff(0.1)
    assertError(self.l.signalOn, self.l, 0.09)
end
TestListener.test_signalOn_negative = function(self)
    local l = Signal.Listener(time_unit_ms)
    assertError(l.signalOn, self.l, -0.001)
end
TestListener.test_signalOff_mismatched = function(self)
    self.l:signalOff(0.1207)
    assertEquals(self.l:getMorse(), '.')
    assertError(self.l.signalOff, self.l, 0.3)
end
TestListener.test_signalOff_no_signalOn = function(self)
    local l = Signal.Listener(time_unit_ms)
    assertError(l.signalOff, l, 0.1)
end
TestListener.test_inverted_signalOff_signalOn = function(self)
    self.l:signalOff(0.1)
    self.l:signalOn(0.3)
    assertError(self.l.signalOff, self.l, 0.25)
end
TestListener.test_getMorse_signalOn = function(self)
    assertEquals(self.l:getMorse(), '')
    
    self.l:signalOff(0.2834)
    assertEquals(self.l:getMorse(), '-')
    
    self.l:signalOn(0.401)
    assertEquals(self.l:getMorse(), '-')
end
TestListener.test_getLastEvent = function(self)
    assertNil(self.l:getLastEvent())
    self.l:signalOff(0.31)
    assertAlmostEquals(self.l:getLastEvent(), 0.31, 1e-12)
end



TestPulseSeq = {}
TestPulseSeq.test_morse_1 = function(self)
    local tu = 0.1 -- time-unit :: 100ms
    local seq = Signal._PulseSeq(tu, '.--. . .')
    
    -- multiples because of rounding errors from multiplication
    assertEquals(seq:getSeq(), {{ 0*tu, 1*tu},
                                { 2*tu, 3*tu},
                                { 6*tu, 3*tu},
                                {10*tu, 1*tu},
                                {14*tu, 1*tu},
                                {18*tu, 1*tu}})
    
    assert(    seq:isOn(0))
    assert(not seq:isOn(0.10000000001))
    assert(    seq:isOn(1.06)) -- last dot in 'p'
    assert(not seq:isOn(1.13))
    
    assert(    seq:isOn(1.41))
    assert(not seq:isDone(1.41))
    
    assert(not seq:isDone(1.9))
    assert(    seq:isDone(1.90000000001))
    assert(not seq:isOn(1.90000000001))
end
TestPulseSeq.test_morse_2 = function(self)
    local tu = 0.2
    local seq = Signal._PulseSeq(tu, '.\t--')
    assertEquals(seq:getSeq(), {{ 0*tu, 1*tu},
                                { 8*tu, 3*tu},
                                {12*tu, 3*tu}
                               })
end
TestPulseSeq.test_addPulse = function(self)
    local tu = 0.1
    local s = Signal._PulseSeq(tu, '. --')
    assert(s:isDone(1.100000000001))
    s:addPulse(1.2, tu*3)
    assert(not s:isDone(1.4))
    assert(s:isOn(1.5))
    assert(s:isDone(1.50000000001))
    local morse = s:getMorse()
    assertEquals(morse, '. ---')
end
TestPulseSeq.test_addPulse_2 = function(self)
    local tu = 0.1
    local s = Signal._PulseSeq(tu)
    s:addPulse(0, 0.3)
    assert(s:isDone(0.30000000001))
    assertEquals(s:getMorse(), '-')
end
TestPulseSeq.test_addPulse_3 = function(self)
    local tu = 0.1
    local s = Signal._PulseSeq(tu)
    s:addPulse(0, 0.09972)
    assert(s:isDone(0.09990))
    local morse = s:getMorse()
    assertEquals(morse, '.')
    local calc_tu = s:computeTimeUnit()
    assertAlmostEquals(calc_tu, 0.09972, 1e-7)
end
--TODO: more computeTimeUnit verification (if and when known to be useful)
TestPulseSeq.test_addPulse_overlap = function(self)
    local tu = 0.1
    local s = Signal._PulseSeq(tu, '-')
    assertEquals(s:getMorse(), '-')
    assert(not s:isDone(0.2))
    assertError(s.addPulse, s, 0.1, tu)
    assertEquals(s:getMorse(), '-')
end
TestPulseSeq.test_addPulse_negative = function(self)
    local s = Signal._PulseSeq(0.1)
    assertError(s.addPulse, s, -0.03, 0.1001)
    assertError(s.addPulse, s, 0.03, -0.1001)
end
TestPulseSeq.test_addPulse_zero_duration = function(self)
    local s = Signal._PulseSeq(0.1)
    assertError(s.addPulse, s, 0.1, 0)
end


LuaUnit:run()

